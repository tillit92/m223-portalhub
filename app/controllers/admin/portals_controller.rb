class Admin::PortalsController < Admin::BaseController
  before_action :set_portal, only: %i[ edit update destroy ]

  def index
    @portals = Portal.includes(:bookings).order(:departure_time)
  end

  def new
    @portal = Portal.new
  end

  def create
    @portal = Portal.new(portal_params)

    if @portal.save
      Activity.record("portal_created", "hat das Portal #{@portal.name} angelegt (Dimension #{@portal.dimension}, Kapazität #{@portal.capacity})")
      redirect_to admin_portals_path, notice: "Portal angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @portal.update_under_lock(portal_params)
      log_changes
      redirect_to admin_portals_path, notice: "Portal gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    bookings = @portal.bookings.count
    @portal.destroy!
    Activity.record("portal_deleted", "hat das Portal #{@portal.name} gelöscht (#{bookings} Reservierungen entfernt)")
    redirect_to admin_portals_path, notice: "Portal gelöscht."
  end

  private
    def set_portal
      @portal = Portal.find(params[:id])
    end

    LABELS = { "name" => "Name", "dimension" => "Dimension", "departure_time" => "Abflug", "capacity" => "Kapazität" }.freeze

    # One entry per real change, naming what changed from what to what.
    def log_changes
      changes = Activity.change_list(@portal, LABELS)
      return if changes.empty?

      Activity.record("portal_updated", "hat das Portal #{@portal.name} geändert (#{changes.join(", ")})")
    end

    def portal_params
      params.expect(portal: %i[ name dimension departure_time capacity ])
    end
end
