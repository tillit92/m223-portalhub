require "test_helper"

# Der kritische Multiuser-Fall des Projekts: Zehn Reisende greifen im selben
# Moment nach dem letzten freien Platz, und nur eine Reservierung darf
# gespeichert werden (siehe docs/adr/0002-capacity-enforced-with-portal-lock.md).
#
# Dieser Test läuft bewusst ohne die umschliessende Test-Transaktion, damit die
# Threads wirklich auf der Datenbank konkurrieren. Jeder Thread holt sich eine
# eigene Verbindung und ein eigenes Portal-Objekt.
class PortalConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  TRAVELERS = 10
  PORTAL_NAME = "Concurrency-Portal"
  EMAIL_PATTERN = "concurrency-%d@portalhub.test"

  setup do
    delete_test_data

    @portal = Portal.create!(name: PORTAL_NAME, dimension: "C-137",
      departure_time: 1.day.from_now, capacity: 1)
    @travelers = TRAVELERS.times.map do |index|
      User.create!(name: "Reisender #{index}", email_address: format(EMAIL_PATTERN, index),
        password: "portal-gun-42")
    end
  end

  teardown { delete_test_data }

  test "ten travelers reserving the last seat at once leave exactly one booking" do
    results = reserve_at_the_same_time

    assert_equal 1, results.count(:reserved), "genau eine Reservierung darf gelingen"
    assert_equal TRAVELERS - 1, results.count(:full), "alle anderen sehen das volle Portal"
    assert_equal 1, @portal.bookings.count, "das Portal hat genau eine Buchung"
    assert @portal.reload.full?
  end

  test "the capacity still holds when there are seats for some of them" do
    @portal.update!(capacity: 4)

    results = reserve_at_the_same_time

    assert_equal 4, results.count(:reserved)
    assert_equal TRAVELERS - 4, results.count(:full)
    assert_equal 4, @portal.bookings.count
  end

  # Der eigentliche Beweis für die Sperre. Der Test oben beschreibt zwar den
  # geforderten Fall, trifft das schmale Zeitfenster zwischen Zählen und
  # Buchen aber kaum je. Hier wird eine Reservierung mitten in ihrer
  # Transaktion künstlich aufgehalten, während eine zweite es versucht.
  # Mit Sperre muss die zweite warten und geht leer aus. Ohne Sperre würde
  # sie sich am Zähler vorbeimogeln und denselben letzten Platz buchen.
  test "a second reservation cannot slip into a reservation that is still running" do
    holder_is_inside = Queue.new
    slow_portal = Portal.find(@portal.id)
    hold_the_transaction = ->(_user) { holder_is_inside << true; sleep 0.5; false }

    second_result = nil

    stubbing(slow_portal, :reserved_by?, hold_the_transaction) do
      holder = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection { slow_portal.reserve_seat_for(@travelers.first) }
      end

      holder_is_inside.pop
      second_result = ActiveRecord::Base.connection_pool.with_connection do
        Portal.find(@portal.id).reserve_seat_for(@travelers.second)
      end

      assert_equal :reserved, holder.value, "die erste Reservierung muss den Platz bekommen"
    end

    assert_equal :full, second_result, "die zweite Reservierung muss warten und das volle Portal sehen"
    assert_equal 1, @portal.bookings.count, "der letzte Platz darf nur einmal vergeben werden"
  end

  private
    # Jeder Thread holt zuerst seine eigene Verbindung und sein eigenes
    # Portal-Objekt und meldet sich bereit. Erst wenn alle bereitstehen,
    # fällt das Startsignal: So reservieren sie wirklich gleichzeitig und
    # nicht nacheinander, weil der eine noch eine Verbindung sucht.
    def reserve_at_the_same_time
      ready = Queue.new
      go = Queue.new
      results = Queue.new

      threads = @travelers.map do |traveler|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do |connection|
            portal = Portal.find(@portal.id)
            connection.execute("SELECT 1")
            ready << true
            go.pop
            results << portal.reserve_seat_for(traveler)
          end
        end
      end

      TRAVELERS.times { ready.pop }
      TRAVELERS.times { go << :los }
      threads.each { |thread| thread.join(30) }

      Array.new(results.size) { results.pop }
    end

    def delete_test_data
      Booking.where(portal: Portal.where(name: PORTAL_NAME)).delete_all
      Portal.where(name: PORTAL_NAME).delete_all
      User.where(email_address: TRAVELERS.times.map { format(EMAIL_PATTERN, _1) }).delete_all
    end
end
