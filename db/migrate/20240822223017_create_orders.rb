class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.string :email
      t.string :payment_intent_id
      t.boolean :completed

      t.timestamps
    end
  end
end
