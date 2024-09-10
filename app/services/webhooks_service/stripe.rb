# frozen_string_literal: true

module WebhooksService
  class Stripe
    def self.cs_completed(event)
      session = event['data']['object']
      order = Order.find_by(checkout_session_id: session['id'])
      return unless order

      order.update!(paid: true, email: session['customer_details']['email'])

      order.order_items.each do |item|
        product = item.product
        product.update!(quantity: product.quantity - item.quantity)
      end

      order.update!(amount_shipping: session['total_details']['amount_shipping'], amount_tax: session['total_details']['amount_tax'],
                    shipping_code: session['shipping_cost']['shipping_rate'])

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

      SendOrderConfirmationJob.perform_later(session['customer_details']['email'], order.id)
      AdminOrderConfirmationJob.perform_later(order.id)
    rescue StandardError => e
      Rails.logger.debug(e.message)
    end
  end
end
