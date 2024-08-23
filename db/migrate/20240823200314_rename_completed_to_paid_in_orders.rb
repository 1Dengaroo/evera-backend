class RenameCompletedToPaidInOrders < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :completed, :paid
  end
end
