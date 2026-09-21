# Only a logged-in User may open the live connection. It uses the same signed
# session cookie as the rest of the app; without a valid, still existing session
# the connection is refused.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_user || reject_unauthorized_connection
    end

    private
      def find_user
        session_id = cookies.signed[:session_id]
        Session.find_by(id: session_id)&.user if session_id
      end
  end
end
