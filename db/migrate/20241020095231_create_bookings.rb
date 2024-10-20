class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meeting, null: false, foreign_key: true
      t.integer :price

      t.timestamps
    end
  end
end
