class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      # The acting User. Empty for a failed login, and emptied when the User is
      # deleted, so entries outlive the people in them.
      t.references :user, foreign_key: { on_delete: :nullify }
      # The name as it was when it happened, so an entry stays readable after
      # the User is renamed or deleted.
      t.string :user_name
      t.string :action, null: false
      t.string :details, null: false
      t.datetime :created_at, null: false
    end

    add_index :activities, :created_at
  end
end
