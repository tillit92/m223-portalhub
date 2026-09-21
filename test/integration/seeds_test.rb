require "test_helper"

class SeedsTest < ActionDispatch::IntegrationTest
  setup do
    [ Booking, Portal, User ].each(&:delete_all)
  end

  test "the seed data creates Rick as admin and travelers, and can run repeatedly" do
    2.times { Rails.application.load_seed }

    assert_equal 1, User.where(role: "admin").count
    assert_equal "rick@portalhub.test", User.find_by(role: "admin").email_address
    assert_operator User.where(role: "traveler").count, :>=, 3

    post session_path, params: { email_address: "morty@portalhub.test", password: "wubba-lubba" }
    assert_redirected_to root_path
  end

  test "running the seed data again leaves portals and bookings unchanged" do
    Rails.application.load_seed
    counts = [ User.count, Portal.count, Booking.count ]

    Rails.application.load_seed

    assert_equal counts, [ User.count, Portal.count, Booking.count ]
  end

  test "the seed data has upcoming portals, a full one and a departed one" do
    2.times { Rails.application.load_seed }

    upcoming = Portal.upcoming.to_a
    assert_operator upcoming.size, :>=, 3
    assert upcoming.any?(&:full?), "expected a full upcoming portal"
    assert upcoming.any? { |portal| portal.free_seats > 0 }, "expected a portal with free seats"
    assert Portal.where(departure_time: ...Time.current).exists?, "expected a departed portal"
  end
end
