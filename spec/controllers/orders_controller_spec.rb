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
        { 'id': '1', 'quantity' => '2', 'size' => 'M' },
        { 'id': '2', 'quantity' => '1' }
      ]
    end
    let(:permitted_items) { items.map(&:with_indifferent_access) }
    let(:user) { create(:user) }
    let(:service_result) { { session_id: 'cs_1GqIC8XnYozEGLjpCz7iRjz8', session_url: 'https://checkout.everafashion.com/cs_1GqIC8XnYozEGLjpCz7iRjz8' } }

    context 'when the request is successful and the user is logged in' do
      before do
        sign_in user
        allow(OrdersService::CreateCheckoutSession).to receive(:new).and_return(instance_double(OrdersService::CreateCheckoutSession, call: service_result))
      end

      it 'calls the CreateOrderService' do
        post :create, params: { items: }

        expect(OrdersService::CreateCheckoutSession).to have_received(:new).with(user:, items: permitted_items)
      end

      it 'returns the session Id and session Url in the response' do
        post :create, params: { items: }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'session_id' => service_result[:session_id], 'session_url' => service_result[:session_url] })
      end
    end

    context 'when the cart is invalid' do
      let(:service_result) { { error: 'Invalid cart', status: :bad_request } }

      before do
        allow(OrdersService::CreateCheckoutSession).to receive(:new).and_return(instance_double(OrdersService::CreateCheckoutSession, call: service_result))
      end

      it 'returns a bad request status' do
        post :create, params: { items: }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Invalid cart' })
      end
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
    end

    it 'returns all paid orders' do
      orders = create_list(:order, 3, paid: true)
      allow(OrdersService::FilterOrders).to receive(:call).and_return(orders)

      get :admin_index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it 'filters orders by email if provided' do
      user_order = create(:order, user:, paid: true)
      allow(OrdersService::FilterOrders).to receive(:call).and_return([user_order])

      get :admin_index, params: { email: user.email }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body).first['id']).to eq(user_order.id)
    end

    it 'filters orders by status if provided' do
      order_with_shipped_status = create(:order, paid: true, delivery: create(:delivery, status: 'shipped'))
      allow(OrdersService::FilterOrders).to receive(:call).and_return([order_with_shipped_status])

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
        updated_order = order
        updated_order.delivery.update(status: 'delivered', tracking_information: '1234567890')
        allow(OrdersService::UpdateOrder).to receive(:call).and_return(updated_order)

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
        allow(OrdersService::UpdateOrder).to receive(:call).and_raise(ActiveRecord::RecordInvalid.new(order))

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
        sign_in user
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
