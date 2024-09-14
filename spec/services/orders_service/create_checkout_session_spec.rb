# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersService::CreateCheckoutSession, type: :service do
  let(:service) { described_class.new(user:, items:) }

  let(:items) do
    [
      { id: '1', quantity: '2', size: 'M' }.with_indifferent_access,
      { id: '2', quantity: '1' }.with_indifferent_access
    ]
  end
  let(:user) { create(:user) }
  let(:subtotal) { 2000 }
  let(:checkout_session_id) { 'cs_1GqIC8XnYozEGLjpCz7iRjz8' }
  let(:checkout_session) { double('Stripe::Checkout::Session', id: checkout_session_id) } # rubocop:disable RSpec/VerifiedDoubles
  let(:order) { instance_double(Order, id: 123, update!: true) }

  context 'when the cart is valid' do
    before do
      allow(CartsService::ValidateCart).to receive(:call).and_return(valid: true)
      allow(CartsService::CalculateCartTotal).to receive(:call).with(items).and_return(subtotal)
      stripe_payment_instance = instance_double(OrdersService::StripePayment)
      allow(OrdersService::StripePayment).to receive(:new).with(email: user.email, items:).and_return(stripe_payment_instance)
      allow(stripe_payment_instance).to receive(:create_checkout_session).and_return(checkout_session)
      allow(OrdersService::CreateOrder).to receive(:call).with(
        checkout_session_id:,
        subtotal:,
        items:
      ).and_return(order)
    end

    it 'validates the cart' do
      service.call
      expect(CartsService::ValidateCart).to have_received(:call).with(items)
    end

    it 'creates a checkout session' do
      service.call
      expect(OrdersService::StripePayment).to have_received(:new).with(email: user.email, items:)
    end

    it 'creates an order with the correct parameters' do
      service.call
      expect(OrdersService::CreateOrder).to have_received(:call).with(
        checkout_session_id:,
        subtotal:,
        items:
      )
    end

    it 'returns the checkout session id' do
      result = service.call
      expect(result[:session_id]).to eq(checkout_session_id)
    end
  end

  context 'when the cart is invalid' do
    before do
      allow(CartsService::ValidateCart).to receive(:call).and_return(valid: false)
    end

    it 'raises an InvalidCartError' do
      expect { service.call }.to raise_error(OrdersService::InvalidCartError, 'Invalid cart')
    end
  end

  context 'when a Stripe error occurs' do
    let(:stripe_error_message) { 'Card was declined' }

    before do
      allow(CartsService::ValidateCart).to receive(:call).and_return(valid: true)
      allow(OrdersService::StripePayment).to receive(:new).and_raise(Stripe::CardError.new(stripe_error_message, 400))
    end

    it 'returns a bad request status with the error message' do
      result = service.call
      expect(result[:error]).to eq(stripe_error_message)
      expect(result[:status]).to eq(:bad_request)
    end
  end

  context 'when a product is not found' do
    before do
      allow(CartsService::ValidateCart).to receive(:call).and_return(valid: true)
      allow(OrdersService::StripePayment).to receive(:new).and_raise(ActiveRecord::RecordNotFound.new('Product not found'))
    end

    it 'returns a not found status with the error message' do
      result = service.call
      expect(result[:error]).to eq('Product not found: Product not found')
      expect(result[:status]).to eq(:not_found)
    end
  end
end
