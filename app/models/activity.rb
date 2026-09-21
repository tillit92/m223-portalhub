# One line of the Aktivitätsprotokoll: who did what, and when. Written by the
# controllers after an action has succeeded; a refused action writes nothing.
class Activity < ApplicationRecord
  ACTIONS = {
    "login" => "Anmeldung",
    "login_failed" => "Anmeldung fehlgeschlagen",
    "logout" => "Abmeldung",
    "booking_created" => "Reservierung",
    "booking_cancelled" => "Stornierung",
    "portal_created" => "Portal angelegt",
    "portal_updated" => "Portal geändert",
    "portal_deleted" => "Portal gelöscht",
    "user_created" => "Benutzer angelegt",
    "user_updated" => "Benutzer geändert",
    "user_deleted" => "Benutzer gelöscht",
    "profile_updated" => "Profil geändert",
    "password_changed" => "Passwort geändert"
  }.freeze

  belongs_to :user, optional: true

  validates :action, inclusion: { in: ACTIONS.keys }
  validates :details, presence: true

  scope :latest, -> { order(created_at: :desc, id: :desc) }

  def self.record(action, details, user: Current.user)
    create!(user: user, user_name: user&.name, action: action, details: details)
  end

  def action_label
    ACTIONS.fetch(action)
  end
end
