require "test_helper"

class ProfileTest < ActionDispatch::IntegrationTest
  PASSWORD = "portal-gun-42"
  NEW_PASSWORD = "neues-passwort-42"

  def change_password(current: PASSWORD, new: NEW_PASSWORD, confirmation: new)
    patch password_profile_path, params: { user: { current_password: current, password: new, password_confirmation: confirmation } }
  end

  test "a visitor is sent to the login page" do
    get profile_path
    assert_redirected_to new_session_path

    patch profile_path, params: { user: { name: "X" } }
    assert_redirected_to new_session_path

    patch password_profile_path, params: { user: { password: NEW_PASSWORD } }
    assert_redirected_to new_session_path
  end

  test "the profile shows name, email and role, for a traveler and for the admin" do
    sign_in_as users(:morty)
    get profile_path
    assert_response :success
    assert_select "input[name=?][value=?]", "user[name]", "Morty Smith"
    assert_select "input[name=?][value=?]", "user[email_address]", "morty@portalhub.test"
    assert_select "main .tag", text: "Reisender"

    sign_in_as users(:rick)
    get profile_path
    assert_select "main .tag", text: "Admin"
  end

  test "the name in the navigation links to the profile" do
    sign_in_as users(:morty)

    get root_path

    assert_select "a.site-nav__user[href=?]", profile_path, text: "Morty Smith"
  end

  test "changing name and email saves them, confirms and logs it" do
    sign_in_as users(:morty)

    assert_difference "Activity.count", 1 do
      patch profile_path, params: { user: { name: "Morty Smith Jr.", email_address: "  MORTY.JR@portalhub.test " } }
    end

    assert_redirected_to profile_path
    follow_redirect!
    assert_select ".flash--notice", /Profil gespeichert/
    assert_equal [ "Morty Smith Jr.", "morty.jr@portalhub.test" ], users(:morty).reload.slice(:name, :email_address).values
    assert_equal "profile_updated", Activity.order(:id).last.action
    assert_match "Name: Morty Smith → Morty Smith Jr.", Activity.order(:id).last.details
  end

  test "saving without changes writes no entry" do
    sign_in_as users(:morty)

    assert_no_difference "Activity.count" do
      patch profile_path, params: { user: { name: "Morty Smith", email_address: "morty@portalhub.test" } }
    end
  end

  test "an empty name is explained at the field and the typed email stays" do
    sign_in_as users(:morty)

    patch profile_path, params: { user: { name: "", email_address: "neu@portalhub.test" } }

    assert_response :unprocessable_entity
    assert_select ".field--error .field__error", "bitte ausfüllen"
    assert_select "input[name=?][value=?]", "user[email_address]", "neu@portalhub.test"
    assert_equal "Morty Smith", users(:morty).reload.name
  end

  test "the header keeps the saved name while a failed change is shown" do
    sign_in_as users(:morty)

    patch profile_path, params: { user: { name: "", email_address: "neu@portalhub.test" } }

    assert_select ".site-nav__user", "Morty Smith"
  end

  test "an email that is already taken is refused" do
    sign_in_as users(:morty)

    patch profile_path, params: { user: { email_address: users(:rick).email_address } }

    assert_response :unprocessable_entity
    assert_select ".field__error", /schon verwendet/
    assert_equal "morty@portalhub.test", users(:morty).reload.email_address
  end

  test "a traveler cannot make themself admin through the profile" do
    sign_in_as users(:morty)

    patch profile_path, params: { user: { name: "Morty Smith", role: "admin" } }

    assert_redirected_to profile_path
    assert users(:morty).reload.traveler?
  end

  test "a new password needs the current one, is saved, confirmed and logged without the password" do
    sign_in_as users(:morty)

    assert_difference "Activity.count", 1 do
      change_password
    end

    assert_redirected_to profile_path
    follow_redirect!
    assert_select ".flash--notice", /Passwort geändert/
    assert_equal "password_changed", Activity.order(:id).last.action
    assert_no_match(/#{NEW_PASSWORD}|#{PASSWORD}/, Activity.order(:id).last.details)

    delete session_path
    post session_path, params: { email_address: "morty@portalhub.test", password: NEW_PASSWORD }
    assert_redirected_to root_path
  end

  test "changing the password ends the other sessions and keeps the current one" do
    sign_in_as users(:morty)
    other = users(:morty).sessions.where.not(id: Current.session.id).first || users(:morty).sessions.create!
    keep = Current.session

    change_password

    assert_not Session.exists?(other.id), "the other session must end"
    assert Session.exists?(keep.id), "the current session must stay"
    get profile_path
    assert_response :success
  end

  test "a wrong current password is explained and nothing changes" do
    sign_in_as users(:morty)

    assert_no_difference "Activity.count" do
      change_password(current: "falsch")
    end

    assert_response :unprocessable_entity
    assert_select ".field--error .field__error", "stimmt nicht"
    assert users(:morty).reload.authenticate(PASSWORD)
  end

  test "a new password that is too short, empty or not confirmed is explained at its field" do
    sign_in_as users(:morty)

    change_password(new: "kurz123")
    assert_response :unprocessable_entity
    assert_select ".field__error", /mindestens 8 Zeichen/

    change_password(new: "", confirmation: "")
    assert_response :unprocessable_entity
    assert_select ".field__error", "bitte ausfüllen"

    change_password(new: NEW_PASSWORD, confirmation: "etwas-anderes")
    assert_response :unprocessable_entity
    assert_select ".field__error", "stimmt nicht überein"

    assert users(:morty).reload.authenticate(PASSWORD), "the password must be unchanged"
  end
end
