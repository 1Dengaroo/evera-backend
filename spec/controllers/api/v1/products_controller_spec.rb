# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let!(:active_product) { FactoryBot.create(:product, active: true) }
  let!(:inactive_product) { FactoryBot.create(:product, active: false) }

  describe 'GET #index' do
    before { get :index }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'returns only active products' do
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['id']).to eq(active_product.id)
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
      it 'returns a not found response' do
        expect do
          get(:show, params: { id: 9999 })
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
