class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Zu viele Versuche. Warte ein paar Minuten und versuch es nochmal." }

  layout "auth"

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      Activity.record("login", "hat sich angemeldet", user: user)
      redirect_to after_authentication_url
    else
      Activity.record("login_failed", "Fehlgeschlagene Anmeldung mit #{attempted_email}", user: nil)
      flash.now[:alert] = "E-Mail oder Passwort stimmt nicht. Versuch es nochmal."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Activity.record("logout", "hat sich abgemeldet")
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
    # People sometimes type their password into the email field, so only
    # something that looks like an email address is written to the log.
    def attempted_email
      email = params[:email_address].to_s.strip
      email.match?(/\A[^\s@]+@[^\s@]+\z/) ? email.first(100) : "(keine E-Mail-Adresse)"
    end
end
