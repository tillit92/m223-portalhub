# Every User's own profile. There is no id anywhere: it is always the current
# User, so nobody can reach someone else's profile.
class ProfilesController < ApplicationController
  before_action :set_user

  LABELS = { "name" => "Name", "email_address" => "E-Mail", "avatar" => "Bild" }.freeze

  def show
  end

  def update
    if @user.update(profile_params)
      log_changes
      redirect_to profile_path, notice: "Profil gespeichert."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def password
    new_password, confirmation = password_params.values_at(:password, :password_confirmation)

    @user.errors.add(:current_password, "stimmt nicht") unless @user.authenticate(password_params[:current_password])
    @user.errors.add(:password, "bitte ausfüllen") if new_password.blank?
    @user.errors.add(:password_confirmation, "stimmt nicht überein") if confirmation != new_password

    if @user.errors.empty? && @user.update(password: new_password, password_confirmation: confirmation)
      Current.user.sessions.where.not(id: Current.session.id).destroy_all
      Activity.record("password_changed", "hat das eigene Passwort geändert (andere Sitzungen wurden beendet)")
      redirect_to profile_path, notice: "Passwort geändert."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    # A separate instance, so the header keeps showing the saved name while a
    # failed change is shown in the form.
    def set_user
      @user = User.find(Current.user.id)
    end

    def profile_params
      params.expect(user: %i[ name email_address avatar ])
    end

    def password_params
      params.expect(user: %i[ current_password password password_confirmation ])
    end

    def log_changes
      changes = Activity.change_list(@user, LABELS)
      return if changes.empty?

      Activity.record("profile_updated", "hat das eigene Profil geändert (#{changes.join(", ")})")
    end
end
