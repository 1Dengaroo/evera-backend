# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsService::CheckoutItemDetails, type: :service do
  describe '.call' do
    let(:items) { [] }

    context 'when the product exists and is active' do
      let(:product) { create(:product, price: 100.0, active: true) }

      let(:items) do
        [
          { 'id' => product.id, 'size' => 'L', 'quantity' => 2 }
        ]
      end

      it 'returns the correct details for a valid product' do
        allow(CartsService::ValidateProduct).to receive(:call).and_return(valid: true, message: 'Valid product')

        result = described_class.call(items)

        expect(result).to eq(
          [
            {
              id: product.id.to_s,
              size: 'L',
              price: product.price,
              isValid: true,
              validationMessage: 'Valid product'
            }
          ]
        )
      end
    end

    context 'when the product does not exist' do
      let(:items) do
        [
          { 'id' => 'nonexistent_id', 'size' => 'M', 'quantity' => 1 }
        ]
      end

      it 'returns product not found for invalid product' do
        result = described_class.call(items)

        expect(result).to eq(
          [
            {
              id: 'nonexistent_id',
              size: 'M',
              price: 0,
              isValid: false,
              validationMessage: 'Product not found.'
            }
          ]
        )
      end
    end

    context 'when the product exists but fails validation' do
      let(:product) { create(:product, price: 150.0, active: true) }

      let(:items) do
        [
          { 'id' => product.id, 'size' => 'S', 'quantity' => 3 }
        ]
      end

      it 'returns invalid product details when validation fails' do
        allow(CartsService::ValidateProduct).to receive(:call).and_return(valid: false, message: 'Out of stock')

        result = described_class.call(items)

        expect(result).to eq(
          [
            {
              id: product.id.to_s,
              size: 'S',
              price: product.price,
              isValid: false,
              validationMessage: 'Out of stock'
            }
          ]
        )
      end
    end
  end
end
