class Portal < ApplicationRecord
  has_many :bookings, dependent: :destroy

  validates :name, :dimension, :departure_time, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  scope :upcoming, -> { where(departure_time: Time.current..).order(:departure_time) }

  # Booked seats are counted, never stored (ADR-0002). Use includes(:bookings)
  # when listing several Portals to avoid one query per row.
  def booked_seats
    bookings.size
  end

  # Never negative, even if data is inconsistent (more Bookings than Capacity).
  def free_seats
    [ capacity - booked_seats, 0 ].max
  end

  def full?
    free_seats.zero?
  end

  def departed?
    departure_time < Time.current
  end
end
