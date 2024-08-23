# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersService::StripePayment do
  let(:email) { 'test@example.com' }
  let(:items) do
    [
      { 'id' => 1, 'quantity' => 2 },
      { 'id' => 2, 'quantity' => 1 }
    ]
  end
  let(:service) { described_class.new(email:, items:) }

  before do
    checkout_session_double = double('Stripe::Checkout::Session', id: 'cs_1GqIC8XnYozEGLjpCz7iRjz8') # rubocop:disable RSpec/VerifiedDoubles

    allow(Stripe::Checkout::Session).to receive(:create).and_return(checkout_session_double)
  end

  describe '#create_checkout_session' do
    context 'when all products are found' do
      before do
        allow(Product).to receive(:find_by).with(id: 1, active: true).and_return(double('Product', name: 'Product 1', price: 10.0)) # rubocop:disable RSpec/VerifiedDoubles
        allow(Product).to receive(:find_by).with(id: 2, active: true).and_return(double('Product', name: 'Product 2', price: 15.5)) # rubocop:disable RSpec/VerifiedDoubles
      end

      it 'creates a Stripe checkout session' do
        checkout_session = service.create_checkout_session

        expect(Stripe::Checkout::Session).to have_received(:create).with(
          payment_method_types: ['card'],
          line_items: [
            {
              price_data: {
                currency: 'usd',
                product_data: { name: 'Product 1' },
                unit_amount: 1000
              },
              quantity: 2
            },
            {
              price_data: {
                currency: 'usd',
                product_data: { name: 'Product 2' },
                unit_amount: 1550
              },
              quantity: 1
            }
          ],
          mode: 'payment',
          success_url: 'http://localhost:3000/success?session_id={CHECKOUT_SESSION_ID}',
          cancel_url: 'http://localhost:3000/cancel',
          customer_email: email
        )
        expect(checkout_session.id).to eq('cs_1GqIC8XnYozEGLjpCz7iRjz8')
      end
    end

    context 'when a product is not found' do
      before do
        allow(Product).to receive(:find_by).with(id: 1, active: true).and_return(double('Product', name: 'Product 1', price: 10.0)) # rubocop:disable RSpec/VerifiedDoubles
        allow(Product).to receive(:find_by).with(id: 2, active: true).and_return(nil)
      end

      it 'raises a StripeError when a product is not found' do
        expect { service.create_checkout_session }.to raise_error(OrdersService::StripePayment::StripeError, 'Product not found')
      end
    end
  end
end