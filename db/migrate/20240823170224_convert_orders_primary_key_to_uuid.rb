class ConvertOrdersPrimaryKeyToUuid < ActiveRecord::Migration[7.2]
  def up
    add_column :orders, :uuid, :uuid, default: 'gen_random_uuid()', null: false

    remove_foreign_key :order_items, :orders
    rename_column :order_items, :order_id, :order_id_old
    add_column :order_items, :order_id, :uuid

    Order.find_each do |order|
      order.update_column(:uuid, SecureRandom.uuid)
    end

    OrderItem.find_each do |order_item|
      order_item.update_column(:order_id, Order.find(order_item.order_id_old).uuid)
    end

    remove_column :orders, :id
    rename_column :orders, :uuid, :id
    execute "ALTER TABLE orders ADD PRIMARY KEY (id);"

    add_foreign_key :order_items, :orders, column: :order_id
    remove_column :order_items, :order_id_old
  end

  def down
    # Reverse the changes
    raise ActiveRecord::IrreversibleMigration
  end
end
