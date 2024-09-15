# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsService::CalculateCartTotal do
  describe '.call' do
    let(:product_one) { create(:product, id: 1, price: 10.00) }
    let(:product_two) { create(:product, id: 2, price: 15.00) }

    context 'when all products are found' do
      it 'calculates the total cart amount correctly' do
        items = [
          { 'id' => product_one.id, 'quantity' => 2 },
          { 'id' => product_two.id, 'quantity' => 3 }
        ]

        total = described_class.call(items)

        expect(total).to eq(65.00)
      end
    end

    context 'when a product is not found' do
      it 'skip the product and calculates the total with the other products' do
        items = [
          { 'id' => product_one.id, 'quantity' => 2 },
          { 'id' => 999, 'quantity' => 3 }
        ]

        total = described_class.call(items)

        expect(total).to eq(20.00)
      end
    end

    context 'when items list is empty' do
      it 'returns a total of 0' do
        items = []

        total = described_class.call(items)

        expect(total).to eq(0)
      end
    end

    context 'when product quantity is zero' do
      it 'returns a total considering the zero quantity' do
        items = [
          { 'id' => product_one.id, 'quantity' => 0 }
        ]

        total = described_class.call(items)

        expect(total).to eq(0)
      end
    end

    context 'when product quantity is negative' do
      it 'calculates the total with negative quantities' do
        items = [
          { 'id' => product_one.id, 'quantity' => -2 },
          { 'id' => product_two.id, 'quantity' => 3 }
        ]

        total = described_class.call(items)

        expect(total).to eq(25.00)
      end
    end
  end
end
