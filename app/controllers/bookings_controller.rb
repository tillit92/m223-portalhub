class BookingsController < ApplicationController
  # Reservieren heisst: der Fachregel im Modell folgen und ihr Ergebnis
  # in eine verständliche Meldung übersetzen.
  MESSAGES = {
    reserved: [ :notice, "Platz reserviert. Gute Reise!" ],
    departed: [ :alert, "Dieses Portal ist schon abgeflogen." ],
    already_booked: [ :alert, "Du hast bereits einen Platz in diesem Portal." ],
    full: [ :alert, "Portal voll! Dieses Portal hat bereits seine maximale Kapazität erreicht. Versuch es mit einer anderen Dimension, Morty!" ],
    busy: [ :alert, "Gerade ist viel los, versuch es gleich nochmal." ]
  }.freeze

  def create
    portal = Portal.find(params[:portal_id])
    kind, message = MESSAGES.fetch(portal.reserve_seat_for(Current.user))

    redirect_to portal, kind => message
  end
end
