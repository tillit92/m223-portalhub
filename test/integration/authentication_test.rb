require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  PASSWORD = "portal-gun-42"

  def log_in(user)
    post session_path, params: { email_address: user.email_address, password: PASSWORD }
  end

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
    log_in users(:morty)

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select ".site-nav__user", "Morty Smith"
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
    log_in users(:morty)
    delete session_path

    assert_redirected_to new_session_path
    get root_path
    assert_redirected_to new_session_path
  end

  test "a signed-in user sees their own name in the navigation" do
    sign_in_as users(:rick)

    get root_path

    assert_response :success
    assert_select ".site-nav__user", "Rick Sanchez"
  end

  test "there is no self-registration and no password reset" do
    get "/users/new"
    assert_response :not_found

    get "/passwords/new"
    assert_response :not_found
  end
end
