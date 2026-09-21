module ApplicationHelper
  # Makes a page live: it listens on the given streams and, when a change is
  # announced, fetches itself again and morphs the differences in place. Only
  # pages that show data use this; forms and the profile must not, or someone
  # could lose what they are typing.
  def live_updates(*streams)
    turbo_refreshes_with(method: :morph, scroll: :preserve)
    safe_join(streams.map { |stream| turbo_stream_from(stream) })
  end

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
