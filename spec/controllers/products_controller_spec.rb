# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:active_product) { FactoryBot.create(:product, active: true, price: 99.99) }
  let!(:inactive_product) { FactoryBot.create(:product, active: false) }
  let!(:other_active_product) { FactoryBot.create(:product, active: true, price: 149.99) }

  describe 'GET #index' do
    before { get :index }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'returns only active products' do
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |product| product['id'] }).to contain_exactly(active_product.id, other_active_product.id)
    end
  end

  describe 'GET #show' do
    context 'when the product exists' do
      before { get :show, params: { id: active_product.id } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns the correct product' do
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(active_product.id)
        expect(json_response['name']).to eq(active_product.name)
      end
    end

    context 'when the product does not exist' do
      it 'returns null' do
        get :show, params: { id: 'invalid_id' }
        expect(response.body).to eq('null')
      end
    end
  end

  describe 'GET #price_by_id' do
    context 'when the product exists and is active' do
      before { get :price_by_id, params: { id: active_product.id } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns the correct price' do
        json_response = JSON.parse(response.body)
        expect(json_response['price'].to_f).to eq(active_product.price)
      end
    end
  end

  describe 'POST #cart_total' do
    let(:cart_items) do
      [
        { id: active_product.id, quantity: 2 },
        { id: other_active_product.id, quantity: 1 }
      ]
    end

    before do
      # Stub the call to CalculateCartTotal service
      allow(ProductsService::CalculateCartTotal).to receive(:call).and_return(349.97)
    end

    context 'with valid items' do
      before { post :cart_total, params: { items: cart_items } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns the stubbed cart total' do
        json_response = JSON.parse(response.body)
        expect(json_response['total']).to eq(349.97)
      end
    end

    context 'with invalid or missing items' do
      it 'raises an error if items are missing' do
        expect do
          post(:cart_total, params: {})
        end.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe 'GET #front_page_products' do
    before { get :front_page_products }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'returns the most recent active products limited to 4' do
      json_response = JSON.parse(response.body)
      expect(json_response.length).to be <= 4
      expect(json_response.map { |product| product['id'] }).to include(active_product.id, other_active_product.id)
    end
  end
end
