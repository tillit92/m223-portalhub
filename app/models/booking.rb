class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :portal

  validates :user_id, uniqueness: { scope: :portal_id }

  # Once the Portal has departed, the Booking is history and stays as it is.
  def cancellable?
    !portal.departed?
  end
end
