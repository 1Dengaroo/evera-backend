class AddSizeToOrderItems < ActiveRecord::Migration[7.2]
  def change
    add_column :order_items, :size, :string, null: true
  end
end
