class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :portal

  validates :user_id, uniqueness: { scope: :portal_id }
end
