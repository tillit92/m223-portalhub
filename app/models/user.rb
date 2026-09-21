class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :bookings, dependent: :destroy

  enum :role, { traveler: "traveler", admin: "admin" }, default: :traveler, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: { message: "bitte ausfüllen" }
  validates :email_address, presence: { message: "bitte ausfüllen" }, uniqueness: { message: "wird schon verwendet" }
  validates :password, length: { minimum: 8, message: "muss mindestens 8 Zeichen haben" }, allow_nil: true

  def first_name
    name.split.first
  end
end
