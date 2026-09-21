class Portal < ApplicationRecord
  has_many :bookings, dependent: :destroy

  validates :name, :dimension, :departure_time, presence: { message: "bitte ausfüllen" }
  validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 1,
    message: "Kapazität muss mind. 1 sein" }
  validate :capacity_covers_bookings, on: :update

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

  # The second writer of the capacity rule (ADR-0002): an Admin changing the
  # Portal takes the same lock as a reservation, so the Capacity can never be
  # lowered below the Bookings of a Traveler who is booking at that moment.
  #
  # On SQLite `save` already opens its own BEGIN IMMEDIATE transaction that
  # covers the validation, so the count in `capacity_covers_bookings` is fresh
  # even without this lock. It is taken anyway to state the rule openly and so
  # it does not depend on that detail.
  #
  # Returns true when saved, false otherwise (the reason is in `errors`).
  def update_under_lock(attributes)
    with_lock { update(attributes) }
  rescue ActiveRecord::StatementTimeout
    errors.add(:base, "Gerade ist viel los, versuch es gleich nochmal.")
    false
  end

  def reserved_by?(user)
    bookings.exists?(user: user)
  end

  # Why a reservation is refused right now, or nil when a seat can be taken.
  # The order matters: a departed Portal is refused first, whatever else holds.
  def refusal_for(user)
    if departed?
      :departed
    elsif reserved_by?(user)
      :already_booked
    elsif full?
      :full
    end
  end

  # The core rule of the project: a Portal never takes more Bookings than its
  # Capacity, even when several Travelers grab the last seat at the same
  # moment (docs/adr/0002-capacity-enforced-with-portal-lock.md).
  #
  # `with_lock` opens a transaction and reloads the Portal inside it. On SQLite
  # every write transaction starts as BEGIN IMMEDIATE, so two reservations run
  # one after the other instead of side by side. That is why the check and the
  # booking must both happen in this block: count first, then book, in one
  # transaction.
  #
  # Reports what happened: :reserved, :departed, :already_booked, :full or
  # :busy. The controller turns that into a message.
  def reserve_seat_for(user)
    with_lock do
      refusal = refusal_for(user)

      if refusal
        refusal
      else
        bookings.create!(user: user)
        :reserved
      end
    end
  rescue ActiveRecord::StatementTimeout
    # SQLite allows only one writer at a time. When the wait is too long,
    # nothing is saved and the Traveler simply tries again.
    :busy
  end

  private
    # Bookings are counted fresh here, inside the lock of update_under_lock.
    def capacity_covers_bookings
      return unless capacity_changed? && capacity.present?

      booked = bookings.count
      if capacity < booked
        errors.add(:capacity, "Kapazität darf nicht kleiner sein als die Anzahl Reservierungen (#{booked}).")
      end
    end
end
