require "test_helper"

class AdminPortalsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:rick) }

  test "the table lists all portals, departed ones included, with capacity and booked seats" do
    get admin_portals_path

    assert_response :success
    assert_equal 5, css_select("tbody tr").size
    assert_admin_row "Morgen-Portal", /C-137/, /\b5\b/, /\b3\b/
    assert_admin_row "Abend-Portal", /J19-Zeta-7/
    assert_admin_row "Gestern-Portal", /Gazorpazorp/
  end

  test "each row offers edit, delete and bookings, and there is a button for a new portal" do
    get admin_portals_path

    assert_select "a[href=?]", edit_admin_portal_path(portals(:soon)), text: "Bearbeiten"
    assert_select "a[href=?]", admin_portal_bookings_path(portals(:soon)), text: "Reservierungen"
    assert_select "form[action=?] button", admin_portal_path(portals(:soon)), text: "Löschen"
    assert_select "a[href=?]", new_admin_portal_path, text: /Neues Portal/
  end

  test "creating a portal confirms it and adds it to the overview" do
    assert_difference "Portal.count", 1 do
      post admin_portals_path, params: { portal: { name: "Blips-und-Chitz-Portal", dimension: "Arcade-7",
        departure_time: "2035-03-01T18:30", capacity: 4 } }
    end

    assert_redirected_to admin_portals_path
    follow_redirect!
    assert_select ".flash--notice", /Portal angelegt/
    assert_admin_row "Blips-und-Chitz-Portal", /Arcade-7/, /01\.03\.2035, 18:30 Uhr/
  end

  test "a capacity below 1 is refused and what was typed stays in the form" do
    assert_no_difference "Portal.count" do
      post admin_portals_path, params: { portal: { name: "Kaputt-Portal", dimension: "X-1",
        departure_time: "2035-03-01T18:30", capacity: 0 } }
    end

    assert_response :unprocessable_entity
    assert_select ".field__error", /Kapazität muss mind\. 1 sein/
    assert_select "input[name=?][value=?]", "portal[name]", "Kaputt-Portal"
    assert_select "input[name=?][value=?]", "portal[dimension]", "X-1"
  end

  test "missing fields say what to fix" do
    post admin_portals_path, params: { portal: { name: "", dimension: "", departure_time: "", capacity: 3 } }

    assert_response :unprocessable_entity
    assert_select ".field--error", 3
  end

  test "editing a portal saves the changes and confirms them" do
    patch admin_portal_path(portals(:night)), params: { portal: { name: "Spaet-Portal", capacity: 8 } }

    assert_redirected_to admin_portals_path
    follow_redirect!
    assert_select ".flash--notice", /Portal gespeichert/
    assert_equal [ "Spaet-Portal", 8 ], portals(:night).reload.slice(:name, :capacity).values
  end

  test "the capacity can be lowered to exactly the number of bookings" do
    patch admin_portal_path(portals(:soon)), params: { portal: { capacity: 3 } }

    assert_redirected_to admin_portals_path
    assert_equal 3, portals(:soon).reload.capacity
  end

  test "a capacity below the number of bookings is refused with that number" do
    patch admin_portal_path(portals(:soon)), params: { portal: { capacity: 2 } }

    assert_response :unprocessable_entity
    assert_select ".field__error", /Anzahl Reservierungen \(3\)/
    assert_select "input[name=?][value=?]", "portal[capacity]", "2"
    assert_equal 5, portals(:soon).reload.capacity
  end

  test "a capacity below 1 is refused when editing too" do
    patch admin_portal_path(portals(:night)), params: { portal: { capacity: 0 } }

    assert_response :unprocessable_entity
    assert_select ".field__error", /Kapazität muss mind\. 1 sein/
    assert_equal 6, portals(:night).reload.capacity
  end

  test "the edit form is filled with the current values and offers cancel" do
    get edit_admin_portal_path(portals(:soon))

    assert_select "input[name=?][value=?]", "portal[name]", "Morgen-Portal"
    assert_select "input[name=?][value=?]", "portal[capacity]", "5"
    assert_select "a[href=?]", admin_portals_path, text: "Abbrechen"
    assert_select "input[type=submit][value=Speichern]"
  end

  test "deleting asks with the number of bookings, then removes the portal and its bookings" do
    get admin_portals_path
    assert_select "form[action=?][data-turbo-confirm*=?]", admin_portal_path(portals(:soon)), "Es gibt 3 Reservierungen"

    assert_no_difference "Booking.count" do
      assert_difference "Portal.count", -1 do
        delete admin_portal_path(portals(:empty))
      end
    end

    assert_difference "Booking.count", -3 do
      assert_difference "Portal.count", -1 do
        delete admin_portal_path(portals(:soon))
      end
    end

    assert_redirected_to admin_portals_path
    follow_redirect!
    assert_select ".flash--notice", /Portal gelöscht/
    assert_select "main", text: /Morgen-Portal/, count: 0
  end

  test "a deleted portal vanishes from a travelers list of bookings" do
    delete admin_portal_path(portals(:soon))

    sign_in_as users(:morty)
    get bookings_path
    assert_select "main h2", text: "Morgen-Portal", count: 0
  end

  test "the confirmation counts a single booking in the singular" do
    bookings(:summer_soon).destroy
    bookings(:rick_soon).destroy

    get admin_portals_path

    assert_select "form[action=?][data-turbo-confirm*=?]", admin_portal_path(portals(:soon)), "Es gibt 1 Reservierung."
  end

  private
    def assert_admin_row(name, *patterns)
      row = css_select("tbody tr").find { |item| item.at_css("th").xpath("text()").text.strip == name }
      assert row, "expected a row for #{name}"
      patterns.each { |pattern| assert_match pattern, row.text }
    end
end
