class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :portal, null: false, foreign_key: true

      t.timestamps
    end

    # A Traveler holds at most one Booking per Portal.
    add_index :bookings, %i[ user_id portal_id ], unique: true
  end
end
