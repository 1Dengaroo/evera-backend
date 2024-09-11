# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsService::UserFilterProducts, type: :service do
  let!(:product_one) { create(:product, name: 'Laptop', price: 1000, created_at: 2.days.ago, active: true) }
  let!(:product_two) { create(:product, name: 'Smartphone', price: 500, created_at: 1.day.ago, active: true) }
  let!(:product_inactive) { create(:product, name: 'Tablet', price: 800, created_at: 3.days.ago, active: false) } # Inactive product

  describe '.call' do
    context 'when no filters are provided' do
      it 'returns all active products sorted by created_at descending' do
        result = described_class.call({})
        expect(result).to eq([product_one, product_two])
      end
    end

    context 'when filtering by name' do
      it 'returns products that match the name case-insensitively' do
        result = described_class.call(name: 'laptop')
        expect(result).to contain_exactly(product_one)
      end

      it 'returns no products if name does not match' do
        result = described_class.call(name: 'unknown')
        expect(result).to be_empty
      end
    end

    context 'when sorting by price' do
      it 'returns products sorted by price ascending' do
        result = described_class.call(sort_by: 'price', sort_direction: 'asc')
        expect(result).to eq([product_two, product_one]) # Sorted by price ascending
      end

      it 'returns products sorted by price descending' do
        result = described_class.call(sort_by: 'price', sort_direction: 'desc')
        expect(result).to eq([product_one, product_two]) # Sorted by price descending
      end
    end

    context 'when sorting by created_at' do
      it 'returns products sorted by created_at ascending' do
        result = described_class.call(sort_by: 'created_at', sort_direction: 'asc')
        expect(result).to eq([product_one, product_two])
      end

      it 'returns products sorted by created_at descending' do
        result = described_class.call(sort_by: 'created_at', sort_direction: 'desc')
        expect(result).to eq([product_two, product_one])
      end
    end
  end
end
