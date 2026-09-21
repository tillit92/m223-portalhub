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
      redirect_to admin_portals_path, notice: "Portal angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @portal.update_under_lock(portal_params)
      redirect_to admin_portals_path, notice: "Portal gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portal.destroy!
    redirect_to admin_portals_path, notice: "Portal gelöscht."
  end

  private
    def set_portal
      @portal = Portal.find(params[:id])
    end

    def portal_params
      params.expect(portal: %i[ name dimension departure_time capacity ])
    end
end
