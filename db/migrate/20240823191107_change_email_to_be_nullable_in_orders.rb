class ChangeEmailToBeNullableInOrders < ActiveRecord::Migration[7.0]
  def change
    change_column_null :orders, :email, true
  end
end
