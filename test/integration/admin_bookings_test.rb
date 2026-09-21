require "test_helper"

class AdminBookingsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:rick) }

  test "the bookings of a portal show who booked" do
    get admin_portal_bookings_path(portals(:soon))

    assert_response :success
    assert_select "h1", /Morgen-Portal/
    assert_select "tbody tr", 3
    assert_select "tbody", /Morty Smith/
    assert_select "tbody", /Summer Smith/
    assert_select "tbody", /rick@portalhub\.test/
  end

  test "a portal without bookings says so" do
    get admin_portal_bookings_path(portals(:empty))

    assert_select "main", /Noch niemand hat reserviert/
  end

  test "each booking of a portal that has not departed asks for confirmation before it is cancelled" do
    get admin_portal_bookings_path(portals(:soon))

    assert_select "form[data-turbo-confirm]", 3
    assert_select "form[action=?][data-turbo-confirm*=?]",
      admin_portal_booking_path(portals(:soon), bookings(:morty_soon)), "Morty Smith"
  end

  test "the admin cancels any traveler's booking and the seat is free again" do
    assert_difference "Booking.count", -1 do
      delete admin_portal_booking_path(portals(:soon), bookings(:morty_soon))
    end

    assert_redirected_to admin_portal_bookings_path(portals(:soon))
    follow_redirect!
    assert_select ".flash--notice", /Reservierung storniert/
    assert_select "tbody tr", 2
    assert_equal 3, portals(:soon).reload.free_seats
  end

  test "a booking of a departed portal cannot be cancelled, not even by the admin" do
    get admin_portal_bookings_path(portals(:departed))
    assert_select "form[data-turbo-confirm]", 0

    assert_no_difference "Booking.count" do
      delete admin_portal_booking_path(portals(:departed), bookings(:morty_departed))
    end

    assert_redirected_to admin_portal_bookings_path(portals(:departed))
    follow_redirect!
    assert_select ".flash--alert", /abgeflogen/
  end

  test "a booking is only found under its own portal" do
    assert_no_difference "Booking.count" do
      delete admin_portal_booking_path(portals(:night), bookings(:morty_soon))
    end

    assert_response :not_found
  end

  test "the admin reserves for himself through the normal traveler flow" do
    assert_difference "Booking.count", 1 do
      post portal_bookings_path(portals(:night))
    end

    assert portals(:night).reserved_by?(users(:rick))
  end
end
