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
  # Filters for the log page. An unknown value is ignored, not an error.
  scope :for_action, ->(action) { where(action: action) if ACTIONS.key?(action) }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.to_s.match?(/\A\d+\z/) }

  # Written after an action has succeeded. A log line that cannot be written
  # (for example SQLite is busy right then) must not turn an action that already
  # happened into an error page, so a database failure is only logged.
  def self.record(action, details, user: Current.user)
    create!(user: user, user_name: user&.name, action: action, details: details)
  rescue ActiveRecord::StatementInvalid => error
    Rails.logger.error("Activity log could not be written (#{action}): #{error.message}")
    nil
  end

  # "Kapazität: 4 → 6" for every attribute of `record` that really changed.
  def self.change_list(record, labels)
    record.saved_changes.slice(*labels.keys).map do |attribute, (from, to)|
      from, to = [ from, to ].map do |value|
        if value.nil? then "(leer)"
        elsif value.respond_to?(:strftime) then value.in_time_zone.strftime("%d.%m.%Y, %H:%M")
        else value
        end
      end
      "#{labels[attribute]}: #{from} → #{to}"
    end
  end

  def action_label
    ACTIONS.fetch(action)
  end
end
