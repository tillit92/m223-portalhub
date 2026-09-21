class Booking < ApplicationRecord
  include LiveUpdates
  refreshes_pages_on "portals"

  belongs_to :user
  belongs_to :portal

  CANCEL_REFUSED_MESSAGE = "Dieses Portal ist schon abgeflogen. Die Reservierung bleibt bestehen.".freeze

  validates :user_id, uniqueness: { scope: :portal_id }

  # Once the Portal has departed, the Booking is history and stays as it is.
  def cancellable?
    !portal.departed?
  end
end
