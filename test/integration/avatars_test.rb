require "test_helper"

# The avatars are a fixed set of pictures that ship with the app. Nobody uploads
# anything: a User picks one of them, or none, and then the initials show.
class AvatarsTest < ActionDispatch::IntegrationTest
  def profile_params(**changes)
    { user: { name: "Morty Smith", email_address: "morty@portalhub.test" }.merge(changes) }
  end

  test "every avatar in the fixed set has an image file" do
    User::AVATARS.each_key do |key|
      assert Rails.root.join("app/assets/images/#{key}.png").exist?, "missing image for #{key}"
    end
  end

  test "the profile offers every avatar and none, with the current one selected" do
    sign_in_as users(:morty)

    get profile_path

    assert_select "input[type=radio][name=?]", "user[avatar]", User::AVATARS.size + 1
    assert_select "input[type=radio][name=?][value=morty][checked]", "user[avatar]"
    User::AVATARS.each_value { |label| assert_select ".avatar-option", text: /#{label}/ }
    assert_select ".avatar-option", text: /Keins/
  end

  test "choosing an avatar saves it, shows it in the navigation and logs it" do
    sign_in_as users(:morty)

    assert_difference "Activity.count", 1 do
      patch profile_path, params: profile_params(avatar: "summer")
    end

    assert_redirected_to profile_path
    assert_equal "summer", users(:morty).reload.avatar
    follow_redirect!
    assert_select ".site-nav__person img.avatar[src*=summer]"
    assert_match "Bild: morty → summer", Activity.order(:id).last.details
  end

  test "an avatar that is not in the fixed set is refused" do
    sign_in_as users(:morty)

    patch profile_path, params: profile_params(avatar: "../../etc/passwd")

    assert_response :unprocessable_entity
    assert_select ".field__error", /nicht erlaubt/
    assert_equal "morty", users(:morty).reload.avatar
  end

  test "choosing no avatar shows the initials" do
    sign_in_as users(:morty)

    patch profile_path, params: profile_params(avatar: "")

    assert_nil users(:morty).reload.avatar
    follow_redirect!
    assert_select ".site-nav__person .avatar--initials[data-initials=MS]"
    assert_select ".site-nav__person img", 0
  end

  test "a user without an avatar gets the initials" do
    sign_in_as users(:beth)

    get root_path

    assert_select ".site-nav__person .avatar--initials[data-initials=BS]"
  end

  test "the user table shows avatars and initials next to the names" do
    sign_in_as users(:rick)

    get admin_users_path

    assert_select "tbody th img.avatar[src*=morty]", 1
    assert_select "tbody th .avatar--initials[data-initials=BS]", 1
    assert_select "tbody th .avatar", User.count
  end

  test "the admin can give a user an avatar" do
    sign_in_as users(:rick)

    get edit_admin_user_path(users(:beth))
    assert_select "input[type=radio][name=?]", "user[avatar]", User::AVATARS.size + 1

    patch admin_user_path(users(:beth)), params: { user: { name: "Beth Smith", email_address: "beth@portalhub.test", role: "traveler", avatar: "beth" } }

    assert_equal "beth", users(:beth).reload.avatar
    assert_match "Bild: (leer) → beth", Activity.order(:id).last.details
  end

  test "the log shows who did it with a picture or initials, also for someone who is gone" do
    Activity.record("login", "hat sich angemeldet", user: users(:morty))
    Activity.create!(user: nil, user_name: "Jerry Smith", action: "login", details: "hat sich angemeldet")
    sign_in_as users(:rick)

    get admin_activities_path

    assert_select "tbody th img.avatar[src*=morty]", 1
    assert_select "tbody th .avatar--initials[data-initials=JS]", 1
  end
end
