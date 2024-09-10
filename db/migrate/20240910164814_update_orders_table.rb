class UpdateOrdersTable < ActiveRecord::Migration[7.2]
  def change
    rename_column :orders, :price, :subtotal
    
    add_column :orders, :amount_shipping, :integer
    add_column :orders, :amount_tax, :integer
    add_column :orders, :shipping_code, :string
  end
end
