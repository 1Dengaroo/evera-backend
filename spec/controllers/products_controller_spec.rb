# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:active_product) { FactoryBot.create(:product, active: true, price: 99.99) }
  let!(:inactive_product) { FactoryBot.create(:product, active: false) }
  let!(:other_active_product) { FactoryBot.create(:product, name: 'Name', active: true, price: 149.99) }

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

    context 'when there are filters' do
      before do
        allow(ProductsService::UserFilterProducts).to receive(:call).and_return([active_product])
        get :index, params: { name: 'Name' }
      end

      it 'calls the ProductsService::UserFilterProducts service' do
        expect(ProductsService::UserFilterProducts).to have_received(:call).with(anything)
      end

      it 'returns the products filtered by the service' do
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(1)
        expect(json_response.map { |product| product['id'] }).to contain_exactly(active_product.id)
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end
    end

    context 'when the filters are invalid' do
      it 'ignores the invalid filters' do
        get :index, params: { invalid: 'Invalid Name' }
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
        expect(json_response.map { |product| product['id'] }).to contain_exactly(active_product.id, other_active_product.id)
      end
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
      it 'returns a not found status' do
        get :show, params: { id: 'nonexistent_id' }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Product not found')
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
