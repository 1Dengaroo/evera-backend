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
      allow(CartsService::CalculateCartTotal).to receive(:call).and_return(349.97)
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

  describe 'GET #admin_index' do
    let!(:admin) { FactoryBot.create(:user, admin: true) }
    let!(:user) { FactoryBot.create(:user, admin: false, email: 'a@a.com') }

    context 'when the user is an admin' do
      before do
        sign_in admin
        allow(ProductsService::AdminFilterProducts).to receive(:call).and_return([active_product, other_active_product])
        get :admin_index, params: { active: 'true' }
      end

      it 'calls the ProductsService::FilterProducts service' do
        expect(ProductsService::AdminFilterProducts).to have_received(:call).with(anything)
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the products filtered by the service' do
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
        expect(json_response.map { |product| product['id'] }).to contain_exactly(active_product.id, other_active_product.id)
      end
    end

    context 'when the user is not an admin' do
      before do
        sign_in user
        allow(ProductsService::AdminFilterProducts).to receive(:call)
        get :admin_index
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not call the ProductsService::FilterProducts service' do
        expect(ProductsService::AdminFilterProducts).not_to have_received(:call)
      end

      it 'returns an unauthorized error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Unauthorized')
      end

      it 'does not return any products' do
        json_response = JSON.parse(response.body)
        expect(json_response['products']).to be_nil
      end
    end
  end

  describe 'POST #cart_item_details' do
    let(:valid_items) do
      [
        { 'id' => '123', 'quantity' => 2, 'size' => 'M' },
        { 'id' => '456', 'quantity' => 1, 'size' => 'L' }
      ]
    end

    let(:invalid_items) do
      [
        { 'id' => '789', 'quantity' => 1, 'size' => 'S' }
      ]
    end

    let(:valid_item_details) do
      [
        {
          id: '123',
          size: 'M',
          price: 50.0,
          isValid: true,
          validationMessage: 'Valid product'
        },
        {
          id: '456',
          size: 'L',
          price: 75.0,
          isValid: true,
          validationMessage: 'Valid product'
        }
      ]
    end

    let(:invalid_item_details) do
      [
        {
          id: '789',
          size: 'S',
          price: 0,
          isValid: false,
          validationMessage: 'Product not found.'
        }
      ]
    end

    before do
      allow(CartsService::CheckoutItemDetails).to receive(:call).and_return(valid_item_details + invalid_item_details)
      allow(CartsService::CalculateCartTotal).to receive(:call).and_return(125.0)
    end

    context 'with valid items' do
      it 'returns the correct item details, total, and cart validation status' do
        post :cart_item_details, params: { items: valid_items + invalid_items }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body).deep_symbolize_keys

        expect(parsed_response[:itemDetails]).to match_array(valid_item_details + invalid_item_details)
        expect(parsed_response[:total]).to eq(125.0)
        expect(parsed_response[:cartIsValid]).to be(false)
      end
    end

    context 'with only valid items' do
      before do
        allow(CartsService::CheckoutItemDetails).to receive(:call).and_return(valid_item_details)
        allow(CartsService::CalculateCartTotal).to receive(:call).and_return(125.0)
      end

      it 'returns a valid cart when all items are valid' do
        post :cart_item_details, params: { items: valid_items }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body).deep_symbolize_keys

        expect(parsed_response[:itemDetails]).to match_array(valid_item_details)
        expect(parsed_response[:total]).to eq(125.0)
        expect(parsed_response[:cartIsValid]).to be(true)
      end
    end

    context 'with invalid parameters' do
      it 'raises a parameter missing error' do
        expect do
          post(:cart_item_details, params: {})
        end.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe 'POST #validate_cart' do
    let(:cart_items) do
      [
        { id: active_product.id, quantity: 2 },
        { id: other_active_product.id, quantity: 1 }
      ]
    end

    before do
      allow(CartsService::ValidateCart).to receive(:call).and_return(valid: true)
    end

    context 'when the cart is valid' do
      before { post :validate_cart, params: { items: cart_items } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns a valid response' do
        json_response = JSON.parse(response.body)
        expect(json_response['valid']).to be(true)
      end
    end

    context 'when the cart is invalid' do
      before do
        allow(CartsService::ValidateCart).to receive(:call).and_return(valid: false, message: 'Invalid cart', status: :unprocessable_entity)
        post :validate_cart, params: { items: cart_items }
      end

      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an invalid response' do
        json_response = JSON.parse(response.body)
        expect(json_response['valid']).to be(false)
        expect(json_response['message']).to eq('Invalid cart')
      end
    end
  end

  describe 'POST #validate_product' do
    let(:item) { { id: active_product.id, quantity: 1 } }

    before do
      allow(CartsService::ValidateProduct).to receive(:call).and_return(valid: true, message: 'Product is valid')
    end

    context 'when the product is valid' do
      before { post :validate_product, params: { item: } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'returns a valid response' do
        json_response = JSON.parse(response.body)
        expect(json_response['valid']).to be(true)
        expect(json_response['message']).to eq('Product is valid')
      end
    end

    context 'when the product is invalid' do
      before do
        allow(CartsService::ValidateProduct).to receive(:call).and_return(valid: false, message: 'Product not found', status: :not_found)
        post :validate_product, params: { item: }
      end

      it 'returns a not found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an invalid response' do
        json_response = JSON.parse(response.body)
        expect(json_response['valid']).to be(false)
        expect(json_response['message']).to eq('Product not found')
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
