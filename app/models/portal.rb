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

  def reserved_by?(user)
    bookings.exists?(user: user)
  end

  # Die zentrale Fachregel: Ein Portal nimmt nie mehr Buchungen an, als es
  # Plätze hat, auch wenn mehrere Reisende gleichzeitig den letzten Platz
  # wollen (docs/adr/0002-capacity-enforced-with-portal-lock.md).
  #
  # `with_lock` öffnet eine Transaktion und lädt das Portal darin neu. Auf
  # SQLite beginnt jede Schreibtransaktion mit BEGIN IMMEDIATE, dadurch
  # laufen zwei Reservierungen nacheinander statt gleichzeitig. Deshalb
  # müssen Prüfung und Buchung in genau diesem Block liegen: Erst zählen,
  # dann buchen, alles in einer Transaktion.
  #
  # Gibt zurück, was passiert ist: :reserved, :departed, :already_booked,
  # :full oder :busy. Die Meldung dazu wählt der Controller.
  def reserve_seat_for(user)
    with_lock do
      if departed?
        :departed
      elsif reserved_by?(user)
        :already_booked
      elsif bookings.count >= capacity
        :full
      else
        bookings.create!(user: user)
        :reserved
      end
    end
  rescue ActiveRecord::StatementTimeout
    # SQLite lässt nur einen Schreiber gleichzeitig zu. Wenn die Wartezeit
    # nicht reicht, ist nichts gespeichert und der Reisende versucht es neu.
    :busy
  end
end
