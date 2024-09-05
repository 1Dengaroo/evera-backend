# frozen_string_literal: true

require 'rails_helper'
require 'sendgrid-ruby'

RSpec.describe NotificationsService::Order::AdminOrderConfirmation, type: :service do
  let(:sendgrid_api) { instance_double(SendGrid::API) }
  let(:response) { instance_double(SendGrid::Response, status_code: '200', body: '{}') }
  let(:order) do
    double( # rubocop:disable RSpec/VerifiedDoubles
      'Order',
      id: '12345',
      price: 2999,
      created_at: Time.current,
      delivery: double('Delivery', address: double('Address', line1: '123 Main St', line2: '', city: 'Boston', state: 'MA', postal_code: '02118'), email: 'customer@example.com'), # rubocop:disable RSpec/VerifiedDoubles
      order_items: [
        double('OrderItem', quantity: 1, size: 'M', product: double('Product', name: 'T-shirt', cover_image: 'https://example.com/tshirt.png', price: 19.99)), # rubocop:disable RSpec/VerifiedDoubles
        double('OrderItem', quantity: 2, size: 'L', product: double('Product', name: 'Hoodie', cover_image: 'https://example.com/hoodie.png', price: 49.99)) # rubocop:disable RSpec/VerifiedDoubles
      ]
    )
  end
  let(:data) do
    {
      personalizations: [
        {
          to: [{ email: ENV['ADMIN_EMAIL'] }],
          subject: 'Order Confirmation',
          dynamic_template_data: {
            line1: '123 Main St',
            line2: '',
            city: 'Boston',
            state: 'MA',
            zipcode: '02118',
            order_number: '12345',
            order_date: order.created_at.strftime('%B %d, %Y'),
            order_items: [
              { name: 'T-shirt', cover_image: 'https://example.com/tshirt.png', quantity: 1, size: 'M', price: 19.99 },
              { name: 'Hoodie', cover_image: 'https://example.com/hoodie.png', quantity: 2, size: 'L', price: 49.99 }
            ],
            total: 29.99,
            email: 'customer@example.com'
          }
        }
      ],
      from: { email: 'denga323@gmail.com', name: 'Evera' },
      template_id: 'd-b04b24aeb69041cfab16f3a834e617f8'
    }
  end

  before do
    allow(SendGrid::API).to receive(:new).and_return(sendgrid_api)
    allow(sendgrid_api).to receive_message_chain(:client, :mail, :_, :post).and_return(response)
  end

  describe '.send' do
    it 'sends an order confirmation email successfully' do
      allow(sendgrid_api.client.mail._('send')).to receive(:post).with(request_body: data).and_return(response)
      expect { described_class.send(order:) }.not_to raise_error
    end

    context 'when SendGrid returns an error' do
      let(:response) { instance_double(SendGrid::Response, status_code: '400', body: '{"errors": [{"message": "Invalid email"}]}') }

      it 'raises a NotificationsError' do
        allow(sendgrid_api.client.mail._('send')).to receive(:post).with(request_body: data).and_return(response)
        expect { described_class.send(order:) }.to raise_error(NotificationsService::NotificationsError, /Invalid email/)
      end
    end
  end
end
