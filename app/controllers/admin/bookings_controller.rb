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
      Activity.record("booking_cancelled", "hat die Reservierung von #{booking.user.name} im Portal #{@portal.name} storniert")
      redirect_to admin_portal_bookings_path(@portal), notice: "Reservierung storniert."
    else
      redirect_to admin_portal_bookings_path(@portal), alert: Booking::CANCEL_REFUSED_MESSAGE
    end
  end

  private
    def set_portal
      @portal = Portal.find(params[:portal_id])
    end
end
