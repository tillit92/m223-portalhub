module PortalsHelper
  def departure_label(portal)
    portal.departure_time.strftime("%d.%m.%Y, %H:%M Uhr")
  end

  def free_seats_label(portal)
    "#{portal.free_seats} von #{portal.capacity} Plätzen frei"
  end

  # One dot per seat: filled when booked, outlined when free.
  def seat_pips(portal)
    tag.span(class: "seats", role: "img", aria: { label: "#{portal.booked_seats} von #{portal.capacity} Plätzen belegt" }) do
      safe_join(Array.new(portal.capacity) { |index| tag.span(class: [ "seat", ("seat--taken" if index < portal.booked_seats) ]) })
    end
  end

  # "Es gibt 3 Reservierungen." / "Es gibt 1 Reservierung."
  def bookings_count_label(portal)
    count = portal.booked_seats
    "Es gibt #{count} #{count == 1 ? "Reservierung" : "Reservierungen"}."
  end

  def delete_portal_prompt(portal)
    consequence = { 0 => nil, 1 => "Sie wird mit gelöscht." }.fetch(portal.booked_seats, "Sie werden mit gelöscht.")
    [ "Portal #{portal.name} wirklich löschen?", bookings_count_label(portal), consequence ].compact.join(" ")
  end
end
