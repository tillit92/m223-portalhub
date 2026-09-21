class BookingsController < ApplicationController
  # Reserving means following the rule in the model and turning its result
  # into a message the Traveler understands.
  MESSAGES = {
    reserved: [ :notice, "Platz reserviert. Gute Reise!" ],
    departed: [ :alert, "Dieses Portal ist schon abgeflogen." ],
    already_booked: [ :alert, "Du hast bereits einen Platz in diesem Portal." ],
    full: [ :alert, "Portal voll! Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!" ],
    busy: [ :alert, Portal::BUSY_MESSAGE ]
  }.freeze

  def index
    @bookings = Current.user.bookings.eager_load(:portal).order("portals.departure_time")
  end

  def create
    portal = Portal.find(params[:portal_id])
    result = portal.reserve_seat_for(Current.user)
    kind, message = MESSAGES.fetch(result)

    # A reserved seat shows up in "Meine Reservierungen"; a refusal stays on the Portal.
    if result == :reserved
      redirect_to bookings_path, kind => message
    else
      redirect_to portal, kind => message
    end
  end

  # Only the current User's own Bookings can be found here, so someone else's
  # Booking is a plain 404.
  def destroy
    booking = Current.user.bookings.find(params[:id])

    if booking.cancellable?
      booking.destroy!
      redirect_to bookings_path, notice: "Reservierung storniert."
    else
      redirect_to bookings_path, alert: Booking::CANCEL_REFUSED_MESSAGE
    end
  end
end
