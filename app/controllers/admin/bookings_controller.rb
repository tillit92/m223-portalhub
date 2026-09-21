class Admin::BookingsController < Admin::BaseController
  before_action :set_portal

  def index
    @bookings = @portal.bookings.includes(:user).order(:created_at)
  end

  # Finds the Booking under its own Portal, so a mismatched URL is a 404.
  def destroy
    booking = @portal.bookings.find(params[:id])

    if booking.cancellable?
      booking.destroy!
      redirect_to admin_portal_bookings_path(@portal), notice: "Reservierung storniert."
    else
      redirect_to admin_portal_bookings_path(@portal), alert: "Dieses Portal ist schon abgeflogen. Die Reservierung bleibt bestehen."
    end
  end

  private
    def set_portal
      @portal = Portal.find(params[:portal_id])
    end
end
