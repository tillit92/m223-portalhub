module ApplicationHelper
  # The question before something with Bookings is deleted: names the subject
  # and how many Bookings go with it.
  def delete_confirmation(subject, bookings_count)
    prompt = "#{subject} wirklich löschen?"

    case bookings_count
    when 0 then "#{prompt} Es gibt 0 Reservierungen."
    when 1 then "#{prompt} Es gibt 1 Reservierung. Sie wird mit gelöscht."
    else "#{prompt} Es gibt #{bookings_count} Reservierungen. Sie werden mit gelöscht."
    end
  end
end
