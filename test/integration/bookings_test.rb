require "test_helper"

class BookingsTest < ActionDispatch::IntegrationTest
  test "a visitor cannot reserve a seat" do
    assert_no_difference "Booking.count" do
      post portal_bookings_path(portals(:night))
    end

    assert_redirected_to new_session_path
  end

  test "reserving a free seat confirms it and takes the seat" do
    sign_in_as users(:morty)

    assert_difference "Booking.count", 1 do
      post portal_bookings_path(portals(:night))
    end

    assert_redirected_to bookings_path
    follow_redirect!
    assert_select ".flash--notice", /Platz reserviert/
    assert_select "main", /Nacht-Portal/

    get portal_path(portals(:night))
    assert_select "main", /Reserviert\s+1/
    assert_select "main", /Frei\s+5/
    assert users(:morty).bookings.exists?(portal: portals(:night))
  end

  test "the seat is gone for everyone else once it is reserved" do
    sign_in_as users(:morty)
    post portal_bookings_path(portals(:night))

    sign_in_as users(:summer)
    get root_path

    assert_select "main", /5 von 6 Plätzen frei/
  end

  test "a traveler with a seat sees no reserve button and cannot book twice" do
    sign_in_as users(:morty)

    get portal_path(portals(:soon))
    assert_select "button", text: "Platz reservieren", count: 0
    assert_select "main", /Dein Platz ist reserviert/

    assert_no_difference "Booking.count" do
      post portal_bookings_path(portals(:soon))
    end

    assert_redirected_to portal_path(portals(:soon))
    follow_redirect!
    assert_select ".flash--alert", /Du hast bereits einen Platz in diesem Portal/
  end

  test "a full portal offers no working reserve button and refuses a forced attempt" do
    sign_in_as users(:beth)

    get portal_path(portals(:full))
    assert_select "button[disabled]", text: "Platz reservieren"
    assert_select "main", /Frei\s+0/

    assert_no_difference "Booking.count" do
      post portal_bookings_path(portals(:full))
    end

    assert_redirected_to portal_path(portals(:full))
    follow_redirect!
    assert_select ".flash--alert", /Portal voll! Dieses Portal hat bereits seine maximale Kapazität erreicht\. Versuch es mit einer anderen Dimension, Morty!/
  end

  test "a departed portal cannot be reserved" do
    sign_in_as users(:beth)

    get portal_path(portals(:departed))
    assert_select "button", text: "Platz reservieren", count: 0

    assert_no_difference "Booking.count" do
      post portal_bookings_path(portals(:departed))
    end

    assert_redirected_to portal_path(portals(:departed))
    follow_redirect!
    assert_select ".flash--alert", /abgeflogen/
  end

  test "a departed portal is refused even for a traveler who already has a seat there" do
    sign_in_as users(:morty)

    post portal_bookings_path(portals(:departed))

    assert_redirected_to portal_path(portals(:departed))
    follow_redirect!
    assert_select ".flash--alert", /abgeflogen/
  end

  test "a busy database is explained instead of showing a technical error" do
    sign_in_as users(:beth)
    portal = portals(:night)
    # Simuliert eine überlastete Datenbank: SQLite meldet Zeitüberschreitung.
    # Alles danach, vom Abfangen bis zur Meldung, ist echt.
    busy = ->(*) { raise ActiveRecord::StatementTimeout, "database is locked" }

    assert_no_difference "Booking.count" do
      stubbing(portal, :with_lock, busy) do
        stubbing(Portal, :find, ->(_id) { portal }) do
          post portal_bookings_path(portal)
        end
      end
    end

    follow_redirect!
    assert_select ".flash--alert", /Gerade ist viel los, versuch es gleich nochmal/
  end
end
