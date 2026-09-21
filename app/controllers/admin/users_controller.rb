class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[ edit update destroy ]

  LABELS = { "name" => "Name", "email_address" => "E-Mail", "avatar" => "Bild" }.freeze

  def index
    @users = User.includes(:bookings).order(:name)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      Activity.record("user_created", "hat den Benutzer #{@user.name} angelegt (#{@user.email_address}, Rolle: #{helpers.role_label(@user.role)})")
      redirect_to admin_users_path, notice: "Benutzer angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = user_params
    attributes = attributes.except(:password) if attributes[:password].blank?

    if changes_own_role?(attributes)
      @user.assign_attributes(attributes.except(:role))
      @user.errors.add(:role, "Du kannst deine eigene Rolle nicht ändern.")
      render :edit, status: :unprocessable_entity
    elsif @user.update(attributes)
      ended = end_sessions_after_change
      log_changes(ended)
      redirect_to admin_users_path, notice: "Benutzer gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == Current.user
      redirect_to admin_users_path, alert: "Du kannst dich nicht selbst löschen."
    else
      bookings = @user.bookings.count

      if @user.destroy
        Activity.record("user_deleted", "hat den Benutzer #{@user.name} gelöscht (#{bookings} Reservierungen entfernt)")
        redirect_to admin_users_path, notice: "Benutzer gelöscht."
      else
        redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: %i[ name email_address role password avatar ])
    end

    # The Admin keeps their own role, so the acting Admin is always still one.
    # The model holds the rule for everyone else (see User).
    def changes_own_role?(attributes)
      @user == Current.user && attributes[:role].present? && attributes[:role] != @user.role
    end

    # A reset password or a changed role must not leave an old session of that
    # User open. The Admin's own current session stays.
    def end_sessions_after_change
      return false unless @user.saved_change_to_password_digest? || @user.saved_change_to_role?

      keep = @user == Current.user ? Current.session.id : nil
      @user.sessions.where.not(id: keep).destroy_all
      true
    end

    def log_changes(sessions_ended)
      changes = Activity.change_list(@user, LABELS)
      if @user.saved_change_to_role?
        from, to = @user.saved_change_to_role.map { |role| helpers.role_label(role) }
        changes << "Rolle: #{from} → #{to}"
      end
      changes << "Passwort neu gesetzt" if @user.saved_change_to_password_digest?
      changes << "Sitzungen beendet" if sessions_ended
      return if changes.empty?

      Activity.record("user_updated", "hat den Benutzer #{@user.name} geändert (#{changes.join(", ")})")
    end
end
