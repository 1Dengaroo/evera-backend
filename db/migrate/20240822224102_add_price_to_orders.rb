class AddPriceToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :price, :integer
  end
end
