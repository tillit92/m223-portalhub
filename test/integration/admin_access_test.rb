require "test_helper"

# Every admin entry point must refuse a visitor and a Traveler, and must not
# change any data when it does. The list is the single place that names them.
class AdminAccessTest < ActionDispatch::IntegrationTest
  test "a visitor is sent to the login page on every admin page and nothing changes" do
    assert_no_changes -> { data_snapshot } do
      admin_requests.each do |verb, path, params|
        public_send(verb, path, params: params)

        assert_redirected_to new_session_path, "#{verb.upcase} #{path} must ask a visitor to log in"
      end
    end
  end

  test "a traveler is refused on every admin page and nothing changes" do
    sign_in_as users(:morty)

    assert_no_changes -> { data_snapshot } do
      admin_requests.each do |verb, path, params|
        public_send(verb, path, params: params)

        assert_redirected_to root_path, "#{verb.upcase} #{path} must refuse a traveler"
      end
    end
  end

  test "the refusal is explained to the traveler" do
    sign_in_as users(:morty)

    get admin_portals_path
    follow_redirect!

    assert_select ".flash--alert", /Berechtigung fehlt/
  end

  test "the admin link is shown to the admin only" do
    sign_in_as users(:rick)
    get root_path
    assert_select ".site-nav a[href=?]", admin_portals_path, text: "Admin"

    sign_in_as users(:morty)
    get root_path
    assert_select ".site-nav a[href=?]", admin_portals_path, count: 0
  end

  test "the admin is let into every admin page" do
    sign_in_as users(:rick)

    get admin_portals_path
    assert_response :success
    get new_admin_portal_path
    assert_response :success
    get edit_admin_portal_path(portals(:soon))
    assert_response :success
    get admin_portal_bookings_path(portals(:soon))
    assert_response :success
  end

  test "nobody can reserve a seat on behalf of someone else" do
    sign_in_as users(:rick)

    assert_no_difference "Booking.count" do
      post "/admin/portals/#{portals(:night).id}/bookings", params: { user_id: users(:beth).id }
    end

    assert_response :not_found
  end

  private
    def admin_requests
      portal = portals(:soon)
      booking = bookings(:morty_soon)

      [
        [ :get, admin_portals_path ],
        [ :get, new_admin_portal_path ],
        [ :post, admin_portals_path, { portal: { name: "Neu", dimension: "X-1", departure_time: 2.days.from_now, capacity: 3 } } ],
        [ :get, edit_admin_portal_path(portal) ],
        [ :patch, admin_portal_path(portal), { portal: { capacity: 9 } } ],
        [ :delete, admin_portal_path(portal) ],
        [ :get, admin_portal_bookings_path(portal) ],
        [ :delete, admin_portal_booking_path(portal, booking) ]
      ]
    end

    def data_snapshot
      [ Portal.count, Booking.count, Portal.order(:id).pluck(:name, :capacity) ]
    end
end
