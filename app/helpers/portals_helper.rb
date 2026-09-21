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

  # Names the consequence before a Portal with Bookings is deleted.
  def delete_portal_prompt(portal)
    count = portal.booked_seats
    prompt = "Portal #{portal.name} wirklich löschen?"

    case count
    when 0 then "#{prompt} Es gibt 0 Reservierungen."
    when 1 then "#{prompt} Es gibt 1 Reservierung. Sie wird mit gelöscht."
    else "#{prompt} Es gibt #{count} Reservierungen. Sie werden mit gelöscht."
    end
  end
end
