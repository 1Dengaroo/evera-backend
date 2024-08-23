class RenamePaymentIntentIdToCheckoutSessionId < ActiveRecord::Migration[7.2]
  def change
    rename_column :orders, :payment_intent_id, :checkout_session_id
  end
end
