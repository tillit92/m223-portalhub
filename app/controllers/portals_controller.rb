class PortalsController < ApplicationController
  def index
    @portals = Portal.upcoming.includes(:bookings)
  end

  def show
    @portal = Portal.find(params[:id])
  end
end
