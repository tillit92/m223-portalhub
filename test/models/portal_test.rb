require "test_helper"

class PortalTest < ActiveSupport::TestCase
  test "reserving reports why it was refused and saves nothing" do
    assert_no_difference "Booking.count" do
      assert_equal :departed, portals(:departed).reserve_seat_for(users(:beth))
      assert_equal :already_booked, portals(:soon).reserve_seat_for(users(:morty))
      assert_equal :full, portals(:full).reserve_seat_for(users(:beth))
    end
  end

  test "a departed portal is refused even for a traveler who already has a seat" do
    assert_equal :departed, portals(:departed).reserve_seat_for(users(:morty))
  end

  test "reserving the last free seat is allowed and fills the portal" do
    portal = portals(:soon)
    portal.bookings.create!(user: users(:beth))

    assert_equal 1, portal.free_seats
    assert_equal :reserved, portal.reserve_seat_for(users(:birdperson))
    assert portal.reload.full?
  end

  # A busy timeout is the one database error a Traveler can trigger by just
  # being unlucky, so it is reported like any other refusal, not raised.
  test "a database busy timeout is reported as busy" do
    portal = portals(:night)

    busy = ->(*) { raise ActiveRecord::StatementTimeout, "database is locked" }

    assert_no_difference "Booking.count" do
      stubbing(portal, :with_lock, busy) do
        assert_equal :busy, portal.reserve_seat_for(users(:beth))
      end
    end
  end
end
