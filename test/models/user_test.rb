require "test_helper"

# "There is always an Admin" is a rule of the data, not just of one form. Two
# Admins acting at the same moment can only get past the controller checks one
# after the other, so the model has to hold the rule itself. That is why this is
# tested on the model: through HTTP the rule is only reachable by a race.
class UserTest < ActiveSupport::TestCase
  test "the last admin cannot be demoted" do
    rick = users(:rick)

    assert_not rick.update(role: :traveler)

    assert_includes rick.errors[:role], "Es muss mindestens ein Admin bleiben."
    assert rick.reload.admin?
  end

  test "the last admin cannot be deleted" do
    rick = users(:rick)

    assert_not rick.destroy

    assert_includes rick.errors[:base], "Der letzte Admin kann nicht gelöscht werden."
    assert User.exists?(rick.id)
  end

  test "an admin can be demoted or deleted while another admin remains" do
    second = User.create!(name: "Evil Morty", email_address: "evil@portalhub.test", role: :admin, password: "start-passwort-1")

    assert users(:rick).update(role: :traveler)
    assert_not users(:rick).reload.admin?
    assert second.reload.admin?
    assert_not second.destroy, "now the second one is the last admin"
  end

  test "a traveler can always be changed and deleted" do
    assert users(:morty).update(name: "Morty Prime")
    assert users(:morty).destroy
  end

  test "the password errors are in German" do
    user = User.new(name: "X", email_address: "x@portalhub.test", password: "", password_confirmation: "")
    user.valid?
    assert_includes user.errors[:password], "bitte ausfüllen"
    assert_not_includes user.errors[:password], "can't be blank"

    user = User.new(name: "X", email_address: "x@portalhub.test", password: "langes-passwort", password_confirmation: "anderes-passwort")
    user.valid?
    assert_includes user.errors[:password_confirmation], "stimmt nicht überein"
  end
end
