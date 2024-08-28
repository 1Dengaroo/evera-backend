# frozen_string_literal: true

module WebhooksService
  class Stripe
    def self.cs_completed(event)
      session = event['data']['object']

      order = Order.find_by(checkout_session_id: session['id'])
      return unless order

      order.update(paid: true, email: session['customer_details']['email'])

      order.order_items.each do |item|
        product = item.product
        product.update(quantity: product.quantity - item.quantity)
      end

      shipping_details = session['shipping_details']
      address = Address.create!(
        city: shipping_details['address']['city'],
        country: shipping_details['address']['country'],
        line1: shipping_details['address']['line1'],
        line2: shipping_details['address']['line2'],
        postal_code: shipping_details['address']['postal_code'],
        state: shipping_details['address']['state'],
        name: shipping_details['name']
      )

      order.create_delivery!(
        email: session['customer_details']['email'],
        address:,
        session_id: session['id']
      )

      SendOrderConfirmationJob.perform_later(order.id)
    end
  end
end
