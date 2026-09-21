require "test_helper"

class MyBookingsTest < ActionDispatch::IntegrationTest
  test "a visitor is sent to the login page and cannot cancel anything" do
    get bookings_path
    assert_redirected_to new_session_path

    assert_no_difference "Booking.count" do
      delete booking_path(bookings(:morty_soon))
    end
    assert_redirected_to new_session_path
  end

  test "the page lists my bookings with portal, dimension and departure, soonest first" do
    sign_in_as users(:morty)

    get bookings_path

    assert_response :success
    assert_equal %w[ Gestern-Portal Morgen-Portal Abend-Portal ],
      css_select("main h2").map { |heading| heading.text.strip }
    assert_row "Morgen-Portal", /C-137/, /\d{2}\.\d{2}\.\d{4}, \d{2}:\d{2} Uhr/
  end

  test "bookings for departed portals stay visible and are marked as departed" do
    sign_in_as users(:morty)

    get bookings_path

    assert_row "Gestern-Portal", /ABGEFLOGEN/
  end

  test "the page never shows other travelers' bookings" do
    Booking.create!(user: users(:beth), portal: portals(:night))
    sign_in_as users(:morty)

    get bookings_path

    assert_select "main h2", text: "Nacht-Portal", count: 0
  end

  test "without bookings the page shows an empty state with a way back" do
    sign_in_as users(:beth)

    get bookings_path

    assert_select "main", /Du hast noch keine Reservierung\./
    assert_select "main a[href=?]", root_path
  end

  test "the page links back to the overview, with and without bookings" do
    sign_in_as users(:morty)
    get bookings_path
    assert_select "main a[href=?]", root_path, text: /Zurück zur Übersicht/

    sign_in_as users(:beth)
    get bookings_path
    assert_select "main a[href=?]", root_path, text: /Zurück zur Übersicht/
  end

  test "the navigation links to my bookings" do
    sign_in_as users(:morty)

    get root_path

    assert_select ".site-nav a[href=?]", bookings_path, text: /Meine Reservierungen/
  end

  test "the cancel buttons carry a confirmation prompt that names the portal" do
    sign_in_as users(:morty)

    get bookings_path

    assert_select "form[data-turbo-confirm]", 2
    assert_select "form[action=?][data-turbo-confirm*=?]", booking_path(bookings(:morty_soon)), "Morgen-Portal"
  end

  test "cancelling deletes the booking, confirms it and frees the seat for everyone" do
    sign_in_as users(:morty)

    assert_difference "Booking.count", -1 do
      delete booking_path(bookings(:morty_soon))
    end

    assert_redirected_to bookings_path
    follow_redirect!
    assert_select ".flash--notice", /Reservierung storniert/
    assert_select "main", text: /Morgen-Portal/, count: 0

    sign_in_as users(:beth)
    get root_path
    assert_row "Morgen-Portal", /3 von 5 Plätzen frei/
  end

  test "a cancelled full portal can be booked again" do
    sign_in_as users(:morty)
    delete booking_path(bookings(:morty_full))

    sign_in_as users(:beth)
    assert_difference "Booking.count", 1 do
      post portal_bookings_path(portals(:full))
    end
  end

  test "a booking for a departed portal cannot be cancelled" do
    sign_in_as users(:morty)

    get bookings_path
    assert_select "form[action=?]", booking_path(bookings(:morty_departed)), count: 0

    assert_no_difference "Booking.count" do
      delete booking_path(bookings(:morty_departed))
    end

    follow_redirect!
    assert_select ".flash--alert", /abgeflogen/
  end

  test "someone else's booking cannot be cancelled" do
    sign_in_as users(:beth)

    assert_no_difference "Booking.count" do
      delete booking_path(bookings(:morty_soon))
    end

    assert_response :not_found
  end

  test "the admin cannot cancel someone else's booking through the traveler route" do
    sign_in_as users(:rick)

    assert_no_difference "Booking.count" do
      delete booking_path(bookings(:morty_soon))
    end

    assert_response :not_found
  end
end
