class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :bookings, dependent: :destroy

  # A fixed set of pictures that ship with the app (app/assets/images/<key>.png).
  # Nobody uploads anything; a User picks one of these, or none.
  AVATARS = { "rick" => "Rick", "morty" => "Morty", "summer" => "Summer", "beth" => "Beth", "birdperson" => "Birdperson" }.freeze

  enum :role, { traveler: "traveler", admin: "admin" }, default: :traveler, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_validation { self.avatar = nil if avatar.blank? }
  validates :avatar, inclusion: { in: AVATARS.keys, message: "ist nicht erlaubt" }, allow_nil: true

  validates :name, presence: { message: "bitte ausfüllen" }
  validates :email_address, presence: { message: "bitte ausfüllen" }, uniqueness: { message: "wird schon verwendet" }
  validates :password, length: { minimum: 8, message: "muss mindestens 8 Zeichen haben" }, allow_nil: true

  # There is always at least one Admin. The checks run inside the write
  # transaction, so two Admins acting at the same moment cannot both get past.
  validate :an_admin_remains, on: :update
  before_destroy :keep_the_last_admin, prepend: true
  after_validation :translate_password_errors

  def first_name
    name.split.first
  end

  private
    def other_admins?
      User.admin.where.not(id: id).exists?
    end

    def an_admin_remains
      return unless role_changed? && role_was == "admin" && !admin?

      errors.add(:role, "Es muss mindestens ein Admin bleiben.") unless other_admins?
    end

    def keep_the_last_admin
      return unless admin? && !other_admins?

      errors.add(:base, "Der letzte Admin kann nicht gelöscht werden.")
      throw :abort
    end

    # has_secure_password brings English messages; the app shows German ones.
    def translate_password_errors
      errors.add(:password, "bitte ausfüllen") if errors.delete(:password, :blank).present?
      errors.add(:password_confirmation, "stimmt nicht überein") if errors.delete(:password_confirmation, :confirmation).present?
    end
end
