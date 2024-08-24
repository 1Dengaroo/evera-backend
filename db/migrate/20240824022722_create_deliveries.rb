class CreateDeliveries < ActiveRecord::Migration[7.0]
  def change
    create_table :deliveries do |t|
      t.string :email, null: false
      t.string :status, null: false, default: "manufacturing"
      t.string :tracking_information
      t.string :session_id, null: false
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end

    add_index :deliveries, :session_id, unique: true
  end
end
