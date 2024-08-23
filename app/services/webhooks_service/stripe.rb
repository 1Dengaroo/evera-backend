# frozen_string_literal: true

module WebhooksService
  class Stripe
    def self.cs_completed(event)
      session = event['data']['object']
      session['customer_email']

      order = Order.find_by(checkout_session_id: session.id)
      return unless order

      order.update(completed: true)

      order.order_items.each do |item|
        product = item.product
        product.update(quantity: product.quantity - item.quantity)
      end
    end
  end
end
