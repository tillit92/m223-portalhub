require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  PASSWORD = "portal-gun-42"

  setup { sign_in_as users(:rick) }

  def user_row(name, *patterns)
    assert_row name, *patterns, row: "tbody tr", title: "th"
  end

  test "the table lists all users with email, role and number of bookings" do
    get admin_users_path

    assert_response :success
    assert_equal 5, css_select("tbody tr").size
    cells = user_row("Morty Smith").css("td").map { |cell| cell.text.strip }
    assert_equal "morty@portalhub.test", cells[0]
    assert_equal "Reisender", cells[1]
    assert_equal "3", cells[2], "bookings of Morty"
    assert_match "Admin", user_row("Rick Sanchez").text
  end

  test "each other user can be edited and deleted, the own account cannot be deleted, and there is a button for a new user" do
    get admin_users_path

    assert_select "a[href=?]", edit_admin_user_path(users(:morty)), text: "Bearbeiten"
    assert_select "form[action=?] button", admin_user_path(users(:morty)), text: "Löschen"
    assert_select "form[action=?]", admin_user_path(users(:rick)), count: 0
    assert_select "a[href=?]", new_admin_user_path, text: /Neuer Benutzer/
    assert_select ".admin-tabs a[aria-current=page]", text: "Benutzer"
  end

  test "creating a user confirms it, logs it and lets the new user log in" do
    assert_difference [ "User.count", "Activity.count" ], 1 do
      post admin_users_path, params: { user: { name: "Jerry Smith", email_address: "Jerry@portalhub.test", role: "traveler", password: "start-passwort-1" } }
    end

    assert_redirected_to admin_users_path
    follow_redirect!
    assert_select ".flash--notice", /Benutzer angelegt/
    assert_equal "user_created", Activity.order(:id).last.action
    assert_match "Jerry Smith", Activity.order(:id).last.details
    assert_no_match(/start-passwort-1/, Activity.order(:id).last.details)

    delete session_path
    post session_path, params: { email_address: "jerry@portalhub.test", password: "start-passwort-1" }
    assert_redirected_to root_path
    assert User.find_by!(email_address: "jerry@portalhub.test").traveler?
  end

  test "a new admin can be created" do
    post admin_users_path, params: { user: { name: "Evil Morty", email_address: "evil@portalhub.test", role: "admin", password: "start-passwort-1" } }

    assert User.find_by!(email_address: "evil@portalhub.test").admin?
  end

  test "invalid input is explained at the fields and what was typed stays, except the password" do
    assert_no_difference "User.count" do
      post admin_users_path, params: { user: { name: "", email_address: users(:morty).email_address, role: "traveler", password: "kurz" } }
    end

    assert_response :unprocessable_entity
    assert_select ".field__error", text: "bitte ausfüllen"
    assert_select ".field__error", text: "wird schon verwendet"
    assert_select ".field__error", text: /mindestens 8 Zeichen/
    assert_select "input[name=?][value=?]", "user[email_address]", "morty@portalhub.test"
    assert_select "input[type=password][value]", count: 0
  end

  test "an unknown role is refused instead of crashing" do
    assert_no_difference "User.count" do
      post admin_users_path, params: { user: { name: "X", email_address: "x@portalhub.test", role: "superuser", password: "start-passwort-1" } }
    end

    assert_response :unprocessable_entity
  end

  test "the edit form is filled and offers cancel" do
    get edit_admin_user_path(users(:morty))

    assert_select "input[name=?][value=?]", "user[name]", "Morty Smith"
    assert_select "select[name=?] option[selected][value=traveler]", "user[role]"
    assert_select "a[href=?]", admin_users_path, text: "Abbrechen"
  end

  test "editing changes name, email and role, keeps the password when it is left empty, and logs the change" do
    assert_difference "Activity.count", 1 do
      patch admin_user_path(users(:morty)), params: { user: { name: "Morty Prime", email_address: "prime@portalhub.test", role: "admin", password: "" } }
    end

    assert_redirected_to admin_users_path
    morty = users(:morty).reload
    assert_equal [ "Morty Prime", "prime@portalhub.test", "admin" ], morty.slice(:name, :email_address, :role).values
    assert morty.authenticate(PASSWORD), "the password must be unchanged"
    assert_match "Rolle: Reisender → Admin", Activity.order(:id).last.details
  end

  test "a new password can be set for a user" do
    patch admin_user_path(users(:beth)), params: { user: { name: "Beth Smith", email_address: "beth@portalhub.test", role: "traveler", password: "von-rick-gesetzt-1" } }

    assert users(:beth).reload.authenticate("von-rick-gesetzt-1")
    assert_match "Passwort neu gesetzt", Activity.order(:id).last.details
    assert_no_match(/von-rick-gesetzt-1/, Activity.order(:id).last.details)
  end

  test "the admin can change his own name but not his own role" do
    patch admin_user_path(users(:rick)), params: { user: { name: "Rick C-137", email_address: "rick@portalhub.test", role: "admin" } }
    assert_redirected_to admin_users_path
    assert_equal "Rick C-137", users(:rick).reload.name

    assert_no_difference "Activity.count" do
      patch admin_user_path(users(:rick)), params: { user: { name: "Rick C-137", email_address: "rick@portalhub.test", role: "traveler" } }
    end
    assert_response :unprocessable_entity
    assert_select ".field__error", /eigene Rolle/
    assert users(:rick).reload.admin?
  end

  test "the own role field is disabled in the form" do
    get edit_admin_user_path(users(:rick))

    assert_select "select[name=?][disabled]", "user[role]"
  end

  test "the admin cannot delete himself" do
    assert_no_difference "User.count" do
      delete admin_user_path(users(:rick))
    end

    assert_redirected_to admin_users_path
    follow_redirect!
    assert_select ".flash--alert", /nicht selbst löschen/
  end

  test "deleting asks with the number of bookings, then removes the user, the bookings and the sessions" do
    get admin_users_path
    assert_select "form[action=?][data-turbo-confirm*=?]", admin_user_path(users(:morty)), "Es gibt 3 Reservierungen"

    users(:morty).sessions.create!
    free_before = portals(:soon).free_seats

    assert_difference "Booking.count", -3 do
      assert_difference "User.count", -1 do
        delete admin_user_path(users(:morty))
      end
    end

    assert_redirected_to admin_users_path
    follow_redirect!
    assert_select ".flash--notice", /Benutzer gelöscht/
    assert_equal 0, Session.where(user_id: users(:morty).id).count
    assert_equal free_before + 1, portals(:soon).reload.free_seats, "the seat is free again"
    assert_equal "user_deleted", Activity.order(:id).last.action
  end

  test "entries of a deleted user stay, with the name they had" do
    Activity.record("login", "hat sich angemeldet", user: users(:morty))

    delete admin_user_path(users(:morty))

    entry = Activity.where(action: "login").order(:id).last
    assert_nil entry.user_id
    assert_equal "Morty Smith", entry.user_name
    get admin_activities_path
    assert_select "tbody th", text: "Morty Smith"
  end

  test "an unknown user is not found" do
    get edit_admin_user_path(id: 0)

    assert_response :not_found
  end
end
