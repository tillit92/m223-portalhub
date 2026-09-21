# Live pages: after every committed change, tell all open pages that show this
# kind of record to look again.
#
# Only a signal goes out, never HTML. Each browser then fetches the page itself
# with its own session, so every User gets their own version of it (their own
# reservation, their role) and nobody is sent something meant for someone else.
# The browser that caused the change ignores the signal for its own request, so
# its confirmation message stays (Turbo attaches the request id automatically).
module LiveUpdates
  extend ActiveSupport::Concern

  class_methods do
    def refreshes_pages_on(stream)
      after_commit { Turbo::StreamsChannel.broadcast_refresh_to(stream) }
    end
  end
end
