require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  PASSWORD = "portal-gun-42"

  test "a visitor is sent to the login page when opening the home page" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "the login page is reachable without being logged in" do
    get new_session_path

    assert_response :success
    assert_select "input[name=email_address]"
    assert_select "input[name=password]"
  end

  test "logging in with correct credentials lands on the home page" do
    post session_path, params: { email_address: users(:morty).email_address, password: PASSWORD }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select "h1", /Morty/
  end

  test "the login accepts the email in any letter case" do
    post session_path, params: { email_address: "  MORTY@portalhub.test ", password: PASSWORD }

    assert_redirected_to root_path
  end

  test "a wrong password shows a message, keeps the email and logs nobody in" do
    post session_path, params: { email_address: users(:morty).email_address, password: "falsch" }

    assert_response :unprocessable_entity
    assert_select ".flash", /stimmt nicht/
    assert_select "input[name=email_address][value=?]", users(:morty).email_address

    get root_path
    assert_redirected_to new_session_path
  end

  test "an unknown email shows the same message" do
    post session_path, params: { email_address: "jerry@portalhub.test", password: PASSWORD }

    assert_response :unprocessable_entity
    assert_select ".flash", /stimmt nicht/
  end

  test "logging out ends the session" do
    post session_path, params: { email_address: users(:morty).email_address, password: PASSWORD }
    delete session_path

    assert_redirected_to new_session_path
    get root_path
    assert_redirected_to new_session_path
  end

  test "a logged-in user is not sent back to the login page after the first visit" do
    sign_in_as users(:rick)

    get root_path

    assert_response :success
    assert_select "h1", /Rick/
  end

  test "there is no self-registration and no password reset" do
    get "/users/new"
    assert_response :not_found

    get "/passwords/new"
    assert_response :not_found
  end

  test "the seed data creates Rick as admin and travelers, and can run repeatedly" do
    User.delete_all

    2.times { Rails.application.load_seed }

    assert_equal 1, User.where(role: "admin").count
    assert_equal "rick@portalhub.test", User.find_by(role: "admin").email_address
    assert_operator User.where(role: "traveler").count, :>=, 3

    post session_path, params: { email_address: "morty@portalhub.test", password: "wubba-lubba" }
    assert_redirected_to root_path
  end
end
