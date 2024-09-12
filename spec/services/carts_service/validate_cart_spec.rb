# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsService::ValidateCart, type: :service do
  let(:product_one) { create(:product, quantity: 10, active: true, sizes: %w[S M L]) }
  let(:product_two) { create(:product, quantity: 5, active: true, sizes: %w[S M L]) }
  let(:product_three) { create(:product, quantity: 2, active: false, sizes: %w[S M L]) }

  describe '.call' do
    context 'when all products are valid' do
      it 'returns valid status' do
        items = [
          { id: product_one.id, quantity: 2, size: 'M' },
          { id: product_two.id, quantity: 3, size: 'S' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: true })
      end
    end

    context 'when a product does not exist' do
      it 'returns not found status' do
        items = [
          { id: 0, quantity: 1, size: 'M' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :not_found, message: 'Product not found' })
      end
    end

    context 'when a product is out of stock' do
      it 'returns unprocessable entity status' do
        items = [
          { id: product_one.id, quantity: 2, size: 'M' },
          { id: product_two.id, quantity: 6, size: 'S' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is out of stock' })
      end
    end

    context 'when a product is not active' do
      it 'returns unprocessable entity status' do
        items = [
          { id: product_one.id, quantity: 2, size: 'M' },
          { id: product_three.id, quantity: 1, size: 'S' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is no longer active' })
      end
    end

    context 'when a product quantity is invalid' do
      it 'returns unprocessable entity status when quantity is less than 1' do
        items = [
          { id: product_one.id, quantity: 0, size: 'M' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Quantity must be greater than 0' })
      end

      it 'returns unprocessable entity status when quantity is greater than 10' do
        items = [
          { id: product_one.id, quantity: 10, size: 'M' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Quantity must be less than 10' })
      end
    end

    context 'when a product size is invalid' do
      it 'returns unprocessable entity status' do
        items = [
          { id: product_one.id, quantity: 2, size: 'XL' }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is not available in the selected size' })
      end
    end
  end
end
