class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[ edit update destroy ]

  LABELS = { "name" => "Name", "email_address" => "E-Mail" }.freeze

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
      log_changes
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
      @user.destroy!
      Activity.record("user_deleted", "hat den Benutzer #{@user.name} gelöscht (#{bookings} Reservierungen entfernt)")
      redirect_to admin_users_path, notice: "Benutzer gelöscht."
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: %i[ name email_address role password ])
    end

    # The Admin keeps his role, so there is always at least one Admin.
    def changes_own_role?(attributes)
      @user == Current.user && attributes[:role].present? && attributes[:role] != @user.role
    end

    def log_changes
      changes = @user.saved_changes.slice(*LABELS.keys).map { |attribute, (from, to)| "#{LABELS[attribute]}: #{from} → #{to}" }
      if @user.saved_change_to_role?
        from, to = @user.saved_change_to_role.map { |role| helpers.role_label(role) }
        changes << "Rolle: #{from} → #{to}"
      end
      changes << "Passwort neu gesetzt" if @user.saved_change_to_password_digest?
      return if changes.empty?

      Activity.record("user_updated", "hat den Benutzer #{@user.name} geändert (#{changes.join(", ")})")
    end
end
