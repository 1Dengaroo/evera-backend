# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsService::ValidateCart, type: :service do
  let(:product_one) { create(:product, quantity: 10, active: true) }
  let(:product_two) { create(:product, quantity: 5, active: true) }
  let(:product_three) { create(:product, quantity: 2, active: false) }

  describe '.call' do
    context 'when all products are valid' do
      it 'returns valid status' do
        items = [
          { id: product_one.id, quantity: 2 },
          { id: product_two.id, quantity: 3 }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: true })
      end
    end

    context 'when a product does not exist' do
      it 'returns not found status' do
        items = [
          { id: 0, quantity: 1 }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :not_found })
      end
    end

    context 'when a product is out of stock' do
      it 'returns unprocessable entity status' do
        items = [
          { id: product_one.id, quantity: 2 },
          { id: product_two.id, quantity: 6 }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is out of stock' })
      end
    end

    context 'when a product is not active' do
      it 'returns unprocessable entity status' do
        items = [
          { id: product_one.id, quantity: 2 },
          { id: product_three.id, quantity: 1 }
        ]

        result = described_class.call(items)
        expect(result).to eq({ valid: false, status: :unprocessable_entity, message: 'Product is no longer active' })
      end
    end
  end
end
