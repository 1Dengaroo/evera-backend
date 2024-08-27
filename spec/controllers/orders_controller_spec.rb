# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true, email: 'admin@example.com') }

  before do
    sign_in user
  end

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
    let(:order) { instance_double(Order, id: 123, update!: true) }

    before do
      allow(ProductsService::CalculateCartTotal).to receive(:call).with(permitted_items).and_return(20.0)

      stripe_payment_instance = instance_double(OrdersService::StripePayment)
      allow(OrdersService::StripePayment).to receive(:new).with(items: permitted_items).and_return(stripe_payment_instance)
      allow(stripe_payment_instance).to receive(:create_checkout_session).and_return(checkout_session)

      allow(OrdersService::CreateOrder).to receive(:call).and_return(order)
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

    describe 'GET #index' do
      context 'when user is authenticated' do
        before do
          create_list(:order, 3, user:, paid: true)
        end

        it 'returns the orders for the current user' do
          get :index

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body).size).to eq(3)
        end
      end

      context 'when user is not authenticated' do
        before do
          sign_out user
        end

        it 'returns unauthorized' do
          get :index

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    describe 'GET #track_order' do
      let(:order) { create(:order, user:) }

      context 'when the order exists' do
        it 'returns the order details' do
          get :track_order, params: { id: order.id }

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['id']).to eq(order.id)
        end
      end

      context 'when the order does not exist' do
        it 'returns a not found error' do
          get :track_order, params: { id: 123 }

          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Order not found' })
        end
      end
    end

    describe 'GET #admin_index' do
      before do
        sign_in admin
        create_list(:order, 3, paid: true)
      end

      it 'returns all paid orders' do
        get :admin_index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(3)
      end

      it 'filters orders by email if provided' do
        user_order = create(:order, user:, paid: true)
        get :admin_index, params: { email: user.email }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(1)
        expect(JSON.parse(response.body).first['id']).to eq(user_order.id)
      end

      it 'filters orders by status if provided' do
        create(:order, paid: true, delivery: create(:delivery, status: 'shipped'))
        get :admin_index, params: { status: 'shipped' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(1)
        expect(JSON.parse(response.body).first['delivery']['status']).to eq('shipped')
      end
    end

    describe 'PUT #update' do
      let!(:order) { create(:order) }
      let!(:delivery) { create(:delivery, order:) }

      context 'when user is an admin' do
        before do
          sign_in admin
        end

        it 'updates the order delivery information' do
          put :update, params: {
            id: order.id,
            order: {
              delivery_attributes: {
                status: 'delivered',
                tracking_information: '1234567890',
                address_attributes: {
                  name: 'John Doe',
                  line1: '123 Main St',
                  city: 'Anytown',
                  state: 'CA',
                  postal_code: '12345',
                  country: 'USA'
                }
              }
            }
          }

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['delivery']['status']).to eq('delivered')
          expect(JSON.parse(response.body)['delivery']['tracking_information']).to eq('1234567890')
        end

        it 'returns an error if the update fails' do
          put :update, params: {
            id: order.id,
            order: {
              delivery_attributes: {
                status: nil
              }
            }
          }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when user is not an admin' do
        it 'returns forbidden' do
          put :update, params: { id: order.id }

          expect(response).to have_http_status(:forbidden)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized access' })
        end
      end
    end

    describe 'GET #success' do
      let(:order) { create(:order, checkout_session_id: 'cs_1GqIC8XnYozEGLjpCz7iRjz8') }

      context 'when the order exists' do
        it 'returns the order details' do
          get :success, params: { session_id: order.checkout_session_id }

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['id']).to eq(order.id)
        end
      end

      context 'when the order does not exist' do
        it 'returns a not found error' do
          get :success, params: { session_id: 'invalid_session_id' }

          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Order not found' })
        end
      end
    end
  end
end
