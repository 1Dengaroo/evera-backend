# frozen_string_literal: true

module NotificationsService
  module Order
    class OrderDelivered < NotificationsService::Base
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
                    size: order_item.size
                  }
                end,
                tracking_information: order.delivery.tracking_information,
                name: order.delivery.address.name
              }
            }
          ],
          from: { email: BASE_EMAIL, name: BASE_NAME },
          template_id: 'd-bd2f4cfd3f0d4ebb9a5d32294016d2f5'
        }

        sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        response = sg.client.mail._('send').post(request_body: data)

        raise_error_when_fails(response:)
      end
    end
  end
end
