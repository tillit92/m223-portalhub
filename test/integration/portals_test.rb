require "test_helper"

class PortalsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:morty) }

  test "a visitor is sent to the login page from the overview and the details" do
    sign_out

    get root_path
    assert_redirected_to new_session_path

    get portal_path(portals(:soon))
    assert_redirected_to new_session_path
  end

  test "the overview lists upcoming portals with the soonest departure first" do
    get root_path

    assert_response :success
    assert_equal %w[ Morgen-Portal Abend-Portal Nacht-Portal Cronenberg-Express ],
      css_select("main h2").map { |heading| heading.text.strip }
  end

  test "a departed portal is hidden from the overview" do
    get root_path

    assert_select "main", text: /Gestern-Portal/, count: 0
  end

  test "each portal shows its dimension and the free seats out of its capacity" do
    get root_path

    assert_row "Morgen-Portal", /C-137/, /2 von 5 Plätzen frei/
    assert_row "Nacht-Portal", /C-500/, /6 von 6 Plätzen frei/
    assert_row "Cronenberg-Express", /Cronenberg-Welt/, /4 von 4 Plätzen frei/
  end

  test "the departure is shown in Swiss time" do
    portals(:soon).update!(departure_time: Time.utc(2035, 1, 15, 13, 30))

    get root_path

    assert_select "main", /15\.01\.2035, 14:30 Uhr/
  end

  test "the seat pips draw the booked seats out of the capacity" do
    get root_path

    assert_select ".seats[aria-label=?]", "3 von 5 Plätzen belegt" do
      assert_select ".seat", 5
      assert_select ".seat--taken", 3
    end
    assert_select ".seats[aria-label=?]", "0 von 4 Plätzen belegt" do
      assert_select ".seat", 4
      assert_select ".seat--taken", 0
    end
  end

  test "a full portal stays in the list and is marked as fully booked" do
    get root_path

    assert_row "Abend-Portal", /0 von 3 Plätzen frei/, /AUSGEBUCHT/
    assert_select ".tag", text: "AUSGEBUCHT", count: 1
  end

  test "the free seats follow the bookings and are never stored" do
    bookings(:morty_soon).destroy

    get root_path

    assert_select "main", /3 von 5 Plätzen frei/
  end

  test "a portal with more bookings than capacity never shows negative free seats" do
    portals(:soon).update_column(:capacity, 2)

    get root_path
    assert_row "Morgen-Portal", /0 von 2 Plätzen frei/, /AUSGEBUCHT/

    get portal_path(portals(:soon))
    assert_select "main", /Frei\s+0/
  end

  test "a portal is listed until its departure time and then leaves the overview" do
    departure = portals(:soon).departure_time

    travel_to departure do
      get root_path
      assert_select "main h2", "Morgen-Portal"
    end

    travel_to departure + 1.second do
      get root_path
      assert_select "main h2", text: "Morgen-Portal", count: 0
    end
  end

  test "the overview shows an empty state when no portal is left" do
    Portal.destroy_all

    get root_path

    assert_response :success
    assert_select "main", /Gerade fliegt kein Portal/
  end

  test "the details page shows the portal with capacity, booked and free seats" do
    get portal_path(portals(:soon))

    assert_response :success
    assert_select "h1", "Morgen-Portal"
    assert_select "main", /C-137/
    assert_select "main", /Kapazität\s+5/
    assert_select "main", /Reserviert\s+3/
    assert_select "main", /Frei\s+2/
    assert_select "a[href=?]", root_path, text: /Zurück/
  end

  test "the details page of a full portal is marked as fully booked" do
    get portal_path(portals(:full))

    assert_select ".tag", text: "AUSGEBUCHT"
    assert_select "main", /Frei\s+0/
  end

  test "the details page of a departed portal says it has left" do
    get portal_path(portals(:departed))

    assert_response :success
    assert_select ".tag", text: "ABGEFLOGEN"
  end

  test "an unknown portal is not found" do
    get portal_path(id: 0)

    assert_response :not_found
  end
end
