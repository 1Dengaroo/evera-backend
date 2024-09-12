# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsService::ValidateProduct, type: :service do
  let(:product) { create(:product, quantity: 10, active: true, sizes: %w[S M L]) }

  describe '.call' do
    context 'when the product does not exist' do
      it 'returns not found status' do
        result = described_class.call({ id: 0, quantity: 1, size: 'M' })
        expect(result).to eq({ valid: false, status: :not_found, message: 'Product not found' })
      end
    end

    context 'when the product is out of stock' do
      it 'returns unprocessable entity status' do
        result = described_class.call({ id: product.id, quantity: 20, size: 'M' })
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is out of stock' })
      end
    end

    context 'when the product is not active' do
      it 'returns unprocessable entity status' do
        product.update(active: false)
        result = described_class.call({ id: product.id, quantity: 1, size: 'M' })
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is no longer active' })
      end
    end

    context 'when the product is valid' do
      it 'returns valid status' do
        result = described_class.call({ id: product.id, quantity: 5, size: 'M' })
        expect(result).to eq({ valid: true, message: 'Product is valid' })
      end
    end

    context 'when the product quantity is less than or equal to 0' do
      it 'returns unprocessable entity status' do
        result = described_class.call({ id: product.id, quantity: 0, size: 'M' })
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Quantity must be greater than 0' })
      end
    end

    context 'when the product quantity is greater than or equal to 10' do
      it 'returns unprocessable entity status' do
        result = described_class.call({ id: product.id, quantity: 10, size: 'M' })
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Quantity must be less than 10' })
      end
    end

    context 'when the product size is not available' do
      it 'returns unprocessable entity status' do
        result = described_class.call({ id: product.id, quantity: 1, size: 'XL' })
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is not available in the selected size' })
      end
    end
  end
end
