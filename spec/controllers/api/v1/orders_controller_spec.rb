# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  describe 'POST #create' do
    let(:items) do
      [
        { 'id': '1', 'quantity' => '2' },
        { 'id': '2', 'quantity' => '1' }
      ]
    end
    let(:permitted_items) do
      items.map(&:with_indifferent_access)
    end
    let(:amount_in_cents) { 2000 }
    let(:checkout_session_id) { 'cs_1GqIC8XnYozEGLjpCz7iRjz8' }
    let(:checkout_session) { double('Stripe::Checkout::Session', id: checkout_session_id) } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(ProductsService::CalculateCartTotal).to receive(:call).with(permitted_items).and_return(20.0)

      stripe_payment_instance = instance_double(OrdersService::StripePayment)
      allow(OrdersService::StripePayment).to receive(:new).with(items: permitted_items).and_return(stripe_payment_instance)
      allow(stripe_payment_instance).to receive(:create_checkout_session).and_return(checkout_session)

      allow(OrdersService::CreateOrder).to receive(:call)
    end

    context 'when the request is successful' do
      it 'calculates the total amount in cents' do
        post :create, params: { items: }

        expect(ProductsService::CalculateCartTotal).to have_received(:call).with(permitted_items)
      end

      it 'creates a Stripe checkout session' do
        post :create, params: { items: }

        expect(OrdersService::StripePayment).to have_received(:new).with(items: permitted_items)
        expect(OrdersService::StripePayment.new(items: permitted_items)).to have_received(:create_checkout_session)
      end

      it 'creates an order with the correct parameters' do
        post :create, params: { items: }

        expect(OrdersService::CreateOrder).to have_received(:call).with(
          checkout_session_id:,
          amount_in_cents:,
          items: permitted_items
        )
      end

      it 'returns the session ID in the response' do
        post :create, params: { items: }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'session_id' => checkout_session_id })
      end
    end

    context 'when a StripeError occurs' do
      before do
        stripe_payment_instance = instance_double(OrdersService::StripePayment)
        allow(OrdersService::StripePayment).to receive(:new).with(items: permitted_items).and_return(stripe_payment_instance)
        allow(stripe_payment_instance).to receive(:create_checkout_session).and_raise(Stripe::StripeError, 'Payment failed')
      end

      it 'logs the error and returns a bad request status' do
        post :create, params: { items: }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Payment failed' })
      end
    end

    context 'when a RecordNotFound error occurs' do
      before do
        allow(OrdersService::CreateOrder).to receive(:call).and_raise(ActiveRecord::RecordNotFound, 'Product not found')
      end

      it 'returns a not found status' do
        post :create, params: { items: }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Product not found: Product not found' })
      end
    end
  end
end
