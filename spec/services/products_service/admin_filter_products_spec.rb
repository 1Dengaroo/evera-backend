# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsService::AdminFilterProducts, type: :service do
  let!(:product_one) { create(:product, name: 'Product A', active: true, created_at: 3.days.ago) }
  let!(:product_two) { create(:product, name: 'Product B', active: false, created_at: 2.days.ago) }
  let!(:product_three) { create(:product, name: 'Product C', active: true, created_at: 1.day.ago) }

  describe '.call' do
    context 'when no filters are applied' do
      it 'returns all products' do
        result = described_class.call({})
        expect(result).to contain_exactly(product_one, product_two, product_three)
      end
    end

    context 'when filtering by active status' do
      it 'returns only active products' do
        result = described_class.call(active: 'true')
        expect(result).to contain_exactly(product_one, product_three)
      end

      it 'returns only inactive products' do
        result = described_class.call(active: 'false')
        expect(result).to contain_exactly(product_two)
      end
    end

    context 'when filtering by name' do
      it 'returns products matching the name' do
        result = described_class.call(name: 'Product A')
        expect(result).to contain_exactly(product_one)
      end
    end

    context 'when filtering by created_at date range' do
      it 'returns products created within the date range' do
        result = described_class.call(created_at: { start_date: 2.days.ago.to_s, end_date: 1.day.ago.to_s })
        expect(result).to contain_exactly(product_two, product_three)
      end

      it 'returns no products if the date range is invalid' do
        result = described_class.call(created_at: { start_date: 'invalid', end_date: 'invalid' })
        expect(result).to be_empty
      end
    end

    context 'when sorting by created_at' do
      it 'returns products in ascending order' do
        result = described_class.call(sort_by_date: 'asc')
        expect(result).to eq([product_one, product_two, product_three])
      end

      it 'returns products in descending order' do
        result = described_class.call(sort_by_date: 'desc')
        expect(result).to eq([product_three, product_two, product_one])
      end
    end
  end
end
