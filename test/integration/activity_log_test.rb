require "test_helper"

class ActivityLogTest < ActionDispatch::IntegrationTest
  PASSWORD = "portal-gun-42"

  def last_activity
    Activity.order(:id).last
  end

  test "a login is logged for the user" do
    assert_difference "Activity.count", 1 do
      post session_path, params: { email_address: users(:morty).email_address, password: PASSWORD }
    end

    assert_equal "login", last_activity.action
    assert_equal users(:morty), last_activity.user
    assert_equal "Morty Smith", last_activity.user_name
  end

  test "a failed login is logged with the email that was tried, without a user" do
    assert_difference "Activity.count", 1 do
      post session_path, params: { email_address: "jerry@portalhub.test", password: "falsch" }
    end

    assert_equal "login_failed", last_activity.action
    assert_nil last_activity.user
    assert_match "jerry@portalhub.test", last_activity.details
  end

  test "something typed into the email field that is not an email is not written to the log" do
    post session_path, params: { email_address: "mein-geheimes-passwort", password: "falsch" }

    assert_equal "login_failed", last_activity.action
    assert_no_match(/mein-geheimes-passwort/, last_activity.details)
    assert_match "keine E-Mail-Adresse", last_activity.details
  end

  test "a log entry that cannot be written does not break an action that already worked" do
    sign_in_as users(:morty)
    busy = ->(*) { raise ActiveRecord::StatementTimeout, "database is locked" }

    stubbing(Activity, :create!, busy) do
      delete session_path
    end

    assert_redirected_to new_session_path
    get root_path
    assert_redirected_to new_session_path, "the user is really logged out"
  end

  test "a logout is logged" do
    sign_in_as users(:morty)

    assert_difference "Activity.count", 1 do
      delete session_path
    end

    assert_equal "logout", last_activity.action
    assert_equal users(:morty), last_activity.user
  end

  test "a reservation is logged with the portal" do
    sign_in_as users(:morty)

    assert_difference "Activity.count", 1 do
      post portal_bookings_path(portals(:night))
    end

    assert_equal "booking_created", last_activity.action
    assert_match "Nacht-Portal", last_activity.details
  end

  test "a refused reservation writes no entry" do
    sign_in_as users(:beth)

    assert_no_difference "Activity.count" do
      post portal_bookings_path(portals(:full))
      post portal_bookings_path(portals(:departed))
    end
  end

  test "a traveler cancelling is logged" do
    sign_in_as users(:morty)

    assert_difference "Activity.count", 1 do
      delete booking_path(bookings(:morty_soon))
    end

    assert_equal "booking_cancelled", last_activity.action
    assert_match "Morgen-Portal", last_activity.details
  end

  test "an admin cancelling someone else's booking names both" do
    sign_in_as users(:rick)

    delete admin_portal_booking_path(portals(:soon), bookings(:morty_soon))

    assert_equal "booking_cancelled", last_activity.action
    assert_equal users(:rick), last_activity.user
    assert_match "Morty Smith", last_activity.details
    assert_match "Morgen-Portal", last_activity.details
  end

  test "a refused cancellation writes no entry" do
    sign_in_as users(:morty)

    assert_no_difference "Activity.count" do
      delete booking_path(bookings(:morty_departed))
    end
  end

  test "creating, changing and deleting a portal are logged" do
    sign_in_as users(:rick)

    post admin_portals_path, params: { portal: { name: "Log-Portal", dimension: "L-1", departure_time: "2035-03-01T18:30", capacity: 4 } }
    assert_equal "portal_created", last_activity.action
    assert_match "Log-Portal", last_activity.details

    portal = Portal.find_by!(name: "Log-Portal")
    patch admin_portal_path(portal), params: { portal: { capacity: 6 } }
    assert_equal "portal_updated", last_activity.action
    assert_match "Kapazität: 4 → 6", last_activity.details

    delete admin_portal_path(portal)
    assert_equal "portal_deleted", last_activity.action
    assert_match "Log-Portal", last_activity.details
    assert_match "0 Reservierungen entfernt", last_activity.details
  end

  test "deleting a portal with bookings names how many were removed" do
    sign_in_as users(:rick)

    delete admin_portal_path(portals(:soon))

    assert_match "3 Reservierungen entfernt", last_activity.details
  end

  test "a save without changes and a refused change write no entry" do
    sign_in_as users(:rick)

    assert_no_difference "Activity.count" do
      patch admin_portal_path(portals(:soon)), params: { portal: { capacity: 5 } }
      patch admin_portal_path(portals(:soon)), params: { portal: { capacity: 2 } }
      post admin_portals_path, params: { portal: { name: "", dimension: "", departure_time: "", capacity: 0 } }
    end
  end

  test "the admin sees the newest entries first with who, action and description" do
    Activity.create!(user: users(:morty), user_name: "Morty Smith", action: "login", details: "hat sich angemeldet", created_at: 2.hours.ago)
    Activity.create!(user: users(:beth), user_name: "Beth Smith", action: "booking_created", details: "hat einen Platz im Portal Nacht-Portal reserviert", created_at: 1.hour.ago)
    sign_in_as users(:rick)

    get admin_activities_path

    assert_response :success
    assert_equal [ "Beth Smith", "Morty Smith" ], css_select("tbody tr th").map { |cell| cell.text.strip }.first(2)
    assert_select "tbody", /Nacht-Portal/
    assert_select "tbody .tag", text: "Reservierung"
  end

  test "the log can be filtered by action and by user" do
    Activity.create!(user: users(:morty), user_name: "Morty Smith", action: "login", details: "hat sich angemeldet")
    Activity.create!(user: users(:beth), user_name: "Beth Smith", action: "booking_created", details: "hat einen Platz im Portal Nacht-Portal reserviert")
    sign_in_as users(:rick)

    get admin_activities_path, params: { aktion: "booking_created" }
    assert_equal [ "Beth Smith" ], css_select("tbody tr th").map { |cell| cell.text.strip }

    get admin_activities_path, params: { benutzer: users(:morty).id }
    assert_equal [ "Morty Smith" ], css_select("tbody tr th").map { |cell| cell.text.strip }

    get admin_activities_path, params: { aktion: "login", benutzer: users(:beth).id }
    assert_select "main", /Keine Einträge für diesen Filter/
  end

  test "an invalid filter value is ignored instead of failing" do
    Activity.create!(user: users(:morty), user_name: "Morty Smith", action: "login", details: "hat sich angemeldet")
    sign_in_as users(:rick)

    get admin_activities_path, params: { aktion: "gibt-es-nicht", benutzer: "x'; DROP TABLE users" }

    assert_response :success
    assert_select "tbody tr th", text: "Morty Smith"
  end

  test "an entry stays readable without a user" do
    Activity.create!(user: nil, user_name: nil, action: "login_failed", details: "Fehlgeschlagene Anmeldung mit x@y.test")
    sign_in_as users(:rick)

    get admin_activities_path

    assert_select "tbody", /Fehlgeschlagene Anmeldung mit x@y\.test/
    assert_select "tbody th", /Unbekannt/
  end

  test "the log has an empty state" do
    sign_in_as users(:rick)
    Activity.delete_all

    get admin_activities_path

    assert_select "main", /Noch nichts passiert/
  end

  test "the admin area has a navigation between its parts" do
    sign_in_as users(:rick)

    get admin_activities_path

    assert_select ".admin-tabs a[href=?]", admin_portals_path, text: "Portale"
    assert_select ".admin-tabs a[aria-current=page]", text: "Protokoll"
  end
end
