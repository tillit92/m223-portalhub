require "test_helper"

# Live updates send only a "look again" signal, never HTML: every browser then
# fetches the page itself with its own session (see docs/adr/0003-...).
class LiveUpdatesTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  def signals(stream)
    ActionCable.server.pubsub.broadcasts(stream).size
  end

  def streams_on_page
    css_select("turbo-cable-stream-source").map { |source| Turbo.signed_stream_verifier.verified(source["signed-stream-name"]) }
  end

  # ---- what sends a signal

  test "a reservation tells the open pages to look again" do
    sign_in_as users(:morty)

    assert_broadcasts "portals", 1 do
      post portal_bookings_path(portals(:night))
    end
  end

  test "a cancellation by the traveler and by the admin each send a signal" do
    sign_in_as users(:morty)
    assert_broadcasts("portals", 1) { delete booking_path(bookings(:morty_soon)) }

    sign_in_as users(:rick)
    assert_broadcasts("portals", 1) { delete admin_portal_booking_path(portals(:soon), bookings(:summer_soon)) }
  end

  test "a refused action sends nothing" do
    sign_in_as users(:beth)

    assert_no_broadcasts "portals" do
      post portal_bookings_path(portals(:full))
      post portal_bookings_path(portals(:departed))
      delete booking_path(bookings(:morty_departed))
    end
  end

  test "creating, changing and deleting a portal send signals" do
    sign_in_as users(:rick)

    assert_broadcasts("portals", 1) do
      post admin_portals_path, params: { portal: { name: "Live-Portal", dimension: "L-1", departure_time: "2035-03-01T18:30", capacity: 4 } }
    end

    portal = Portal.find_by!(name: "Live-Portal")
    assert_broadcasts("portals", 1) { patch admin_portal_path(portal), params: { portal: { capacity: 6 } } }
    assert_broadcasts("portals", 1) { delete admin_portal_path(portal) }
  end

  test "deleting a portal that has bookings also signals the removed bookings" do
    sign_in_as users(:rick)

    delete admin_portal_path(portals(:soon))

    assert_operator signals("portals"), :>=, 1
  end

  test "changing a user sends a signal on the users stream" do
    sign_in_as users(:rick)

    assert_broadcasts "users", 1 do
      patch admin_user_path(users(:beth)), params: { user: { name: "Beth S.", email_address: "beth@portalhub.test", role: "traveler" } }
    end
  end

  test "a new log entry sends a signal on the activities stream" do
    assert_broadcasts "activities", 1 do
      post session_path, params: { email_address: users(:morty).email_address, password: "portal-gun-42" }
    end
  end

  test "a signal carries no page content" do
    sign_in_as users(:morty)

    post portal_bookings_path(portals(:night))

    content = JSON.parse(ActionCable.server.pubsub.broadcasts("portals").last)
    assert_match(/\A<turbo-stream action="refresh"/, content)
    assert_no_match(/Nacht-Portal|morty|Morty|<div|<li/, content, "the signal must not carry any page content")
  end

  # ---- which pages listen

  test "the pages that show live data listen on the right streams and refresh by morphing" do
    {
      "portal overview" => [ root_path, %w[ portals ] ],
      "portal details" => [ portal_path(portals(:soon)), %w[ portals ] ],
      "my bookings" => [ bookings_path, %w[ portals ] ],
      "admin portals" => [ admin_portals_path, %w[ portals ] ],
      "admin bookings of a portal" => [ admin_portal_bookings_path(portals(:soon)), %w[ portals ] ],
      "admin users" => [ admin_users_path, %w[ portals users ] ],
      "admin log" => [ admin_activities_path, %w[ activities ] ]
    }.each do |name, (path, expected)|
      sign_in_as users(:rick)

      get path

      assert_equal expected.sort, streams_on_page.sort, "#{name} listens on the wrong streams"
      assert_select "meta[name=turbo-refresh-method][content=morph]", 1, "#{name} must morph"
      assert_select "meta[name=turbo-refresh-scroll][content=preserve]", 1, "#{name} must keep the scroll position"
    end
  end

  test "forms, the profile and the login page do not listen, so nobody loses what they type" do
    get new_session_path
    assert_select "turbo-cable-stream-source", 0

    sign_in_as users(:rick)
    [ profile_path, new_admin_portal_path, edit_admin_portal_path(portals(:soon)), new_admin_user_path, edit_admin_user_path(users(:beth)) ].each do |path|
      get path

      assert_select "turbo-cable-stream-source", 0, "#{path} must not listen"
      assert_select "meta[name=turbo-refresh-method]", 0, "#{path} must not refresh"
    end
  end
end
