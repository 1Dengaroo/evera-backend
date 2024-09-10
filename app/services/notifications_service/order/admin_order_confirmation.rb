# frozen_string_literal: true

module NotificationsService
  module Order
    class AdminOrderConfirmation < NotificationsService::Base
      def self.send(order:)
        data = {
          personalizations: [
            {
              to: [{ email: ADMIN_EMAIL }],
              subject: 'Order Confirmation',
              dynamic_template_data: {
                line1: order.delivery.address.line1,
                line2: order.delivery.address.line2,
                city: order.delivery.address.city,
                state: order.delivery.address.state,
                zipcode: order.delivery.address.postal_code,
                order_number: order.id,
                order_date: order.created_at.strftime('%B %d, %Y'),
                order_items: order.order_items.map do |order_item|
                  {
                    name: order_item.product.name,
                    cover_image: order_item.product.cover_image,
                    quantity: order_item.quantity,
                    size: order_item.size,
                    price: (order_item.product.price / 100.0).round(2)
                  }
                end,
                subtotal: (order.subtotal / 100.0).round(2),
                amount_shipping: (order.amount_shipping / 100.0).round(2),
                amount_tax: (order.amount_tax / 100.0).round(2),
                total: (order.amount_total / 100.0).round(2),
                email: order.delivery.email
              }
            }
          ],
          from: { email: BASE_EMAIL, name: BASE_NAME },
          template_id: 'd-0d17aaf627874850aaa4438c5781c0f9'
        }

        sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        response = sg.client.mail._('send').post(request_body: data)

        raise_error_when_fails(response:)
      end
    end
  end
end
