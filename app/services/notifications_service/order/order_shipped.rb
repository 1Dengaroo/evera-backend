# frozen_string_literal: true

module NotificationsService
  module Order
    class OrderShipped < NotificationsService::Base
      def self.send(to:, order:)
        data = {
          personalizations: [
            {
              to: [{ email: to }],
              subject: 'Order Shipped',
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
                    price: order_item.product.price
                  }
                end,
                total: (order.price / 100.0).round(2),
                tracking_information: order.delivery.tracking_information,
                name: order.delivery.address.name,
                date: Time.current.strftime('%B %d, %Y')
              }
            }
          ],
          from: { email: BASE_EMAIL, name: BASE_NAME },
          template_id: 'd-cdf03ab9665446d188ab6814a4b3e746'
        }

        sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        response = sg.client.mail._('send').post(request_body: data)

        raise_error_when_fails(response:)
      end
    end
  end
end
