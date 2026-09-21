class Portal < ApplicationRecord
  has_many :bookings, dependent: :destroy

  validates :name, :dimension, :departure_time, presence: true

  scope :upcoming, -> { where(departure_time: Time.current..).order(:departure_time) }

  # Booked seats are counted, never stored (ADR-0002). Use includes(:bookings)
  # when listing several Portals to avoid one query per row.
  def booked_seats
    bookings.size
  end

  def free_seats
    capacity - booked_seats
  end

  def full?
    free_seats <= 0
  end

  def departed?
    departure_time < Time.current
  end
end
