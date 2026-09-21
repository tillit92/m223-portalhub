require "test_helper"

# Only a logged-in User may open the live connection.
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with the session cookie of a logged-in user" do
    session = users(:morty).sessions.create!
    cookies.signed[:session_id] = session.id

    connect

    assert_equal users(:morty), connection.current_user
  end

  test "rejects a connection without a session" do
    assert_reject_connection { connect }
  end

  test "rejects a connection whose session has ended" do
    session = users(:morty).sessions.create!
    cookies.signed[:session_id] = session.id
    session.destroy

    assert_reject_connection { connect }
  end

  test "rejects a session cookie that was not signed by the app" do
    cookies[:session_id] = users(:morty).sessions.create!.id

    assert_reject_connection { connect }
  end
end
