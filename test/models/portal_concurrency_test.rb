require "test_helper"

# The critical multiuser case of this project: ten Travelers grab the last free
# seat at the same moment, and only one Booking may be stored
# (see docs/adr/0002-capacity-enforced-with-portal-lock.md).
#
# This test deliberately runs without the wrapping test transaction so the
# threads really compete on the database. Each thread checks out its own
# connection and loads its own Portal object.
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
      User.create!(name: "Morty C-#{132 + index}", email_address: format(EMAIL_PATTERN, index),
        password: "portal-gun-42")
    end
  end

  teardown { delete_test_data }

  test "ten travelers reserving the last seat at once leave exactly one booking" do
    results = reserve_at_the_same_time

    assert_equal 1, results.count(:reserved), "exactly one reservation may succeed"
    assert_equal TRAVELERS - 1, results.count(:full), "everyone else sees the full portal"
    assert_equal 1, @portal.bookings.count, "the portal holds exactly one booking"
    assert @portal.reload.full?
  end

  test "the capacity still holds when there are seats for some of them" do
    @portal.update!(capacity: 4)

    results = reserve_at_the_same_time

    assert_equal 4, results.count(:reserved)
    assert_equal TRAVELERS - 4, results.count(:full)
    assert_equal 4, @portal.bookings.count
  end

  # This is the actual proof of the lock. The test above describes the required
  # scenario, but it hardly ever hits the narrow window between counting and
  # booking: the operations are too fast. So here one reservation is held open
  # in the middle of its transaction while a second one tries to get in. With
  # the lock the second must wait and comes away empty handed. Without it, it
  # would slip past the counter and book the very same last seat.
  #
  # The hold is shorter than the `timeout` in config/database.yml, so the
  # waiting reservation is served instead of giving up as busy.
  test "a second reservation cannot slip into a reservation that is still running" do
    second_result = nil

    holder_result = with_a_reservation_held_open(@travelers.first) do
      second_result = ActiveRecord::Base.connection_pool.with_connection do
        Portal.find(@portal.id).reserve_seat_for(@travelers.second)
      end
    end

    assert_equal :reserved, holder_result, "the first reservation must get the seat"
    assert_equal :full, second_result, "the second reservation must wait and then see a full portal"
    assert_equal 1, @portal.bookings.count, "the last seat may only be given away once"
  end

  # The second writer of the capacity rule: the Admin lowering the Capacity
  # while a Traveler is reserving. The Portal has room for two, one seat is
  # taken, and a second reservation is held open in the middle of its
  # transaction. Lowering the Capacity to one at that moment looks fine to a
  # check that counts one Booking. The change has to wait for the running
  # reservation, sees two Bookings and is refused, so the Portal is never left
  # over its Capacity.
  #
  # This test proves the behaviour, not the lock: unlike the reservation test
  # above it still passes if `with_lock` is removed from `update_under_lock`,
  # because on SQLite `save` opens its own BEGIN IMMEDIATE transaction around
  # the validation. See the note in Portal#update_under_lock.
  test "lowering the capacity cannot slip past a reservation that is still running" do
    @portal.update!(capacity: 2)
    @portal.bookings.create!(user: @travelers.first)

    lowered = nil

    holder_result = with_a_reservation_held_open(@travelers.second) do
      lowered = ActiveRecord::Base.connection_pool.with_connection do
        Portal.find(@portal.id).update_under_lock(capacity: 1)
      end
    end

    assert_equal :reserved, holder_result, "the reservation running first must get its seat"
    assert_not lowered, "lowering below the number of bookings must be refused"
    assert_equal 2, @portal.reload.capacity
    assert_equal 2, @portal.bookings.count
  end

  private
    # Starts a reservation for `traveler` on its own thread and holds it open in
    # the middle of its transaction (half a second, shorter than the `timeout` in
    # config/database.yml). While it is held, the block runs and can try to get
    # in. Returns what the held reservation reported.
    def with_a_reservation_held_open(traveler)
      holder_is_inside = Queue.new
      slow_portal = Portal.find(@portal.id)
      hold_the_transaction = ->(_user) { holder_is_inside << true; sleep 0.5; false }

      stubbing(slow_portal, :reserved_by?, hold_the_transaction) do
        holder = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection { slow_portal.reserve_seat_for(traveler) }
        end

        holder_is_inside.pop
        yield
        holder.value
      end
    end

    # Every thread first takes its own connection and its own Portal object and
    # reports that it is ready. Only once all of them stand ready does the start
    # signal fall, so they really reserve at the same moment instead of queueing
    # up behind each other while one is still looking for a connection.
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
      threads.each { |thread| assert thread.join(30), "a reserving thread did not finish" }

      Array.new(results.size) { results.pop }
    end

    def delete_test_data
      Booking.where(portal: Portal.where(name: PORTAL_NAME)).delete_all
      Portal.where(name: PORTAL_NAME).delete_all
      User.where(email_address: TRAVELERS.times.map { format(EMAIL_PATTERN, _1) }).delete_all
    end
end
