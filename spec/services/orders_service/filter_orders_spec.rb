# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersService::FilterOrders, type: :service do
  let!(:order_one) { create(:order, email: 'test1@example.com', paid: true, created_at: 2.days.ago) }
  let!(:order_two) { create(:order, email: 'test2@example.com', paid: true, created_at: 1.day.ago) }
  let!(:delivery) { create(:delivery, status: 'shipped', order: order_one) }

  describe '.call' do
    it 'returns all paid orders by default' do
      result = described_class.call({})
      expect(result).to contain_exactly(order_one, order_two)
    end

    it 'filters orders by email' do
      result = described_class.call(email: 'test1@example.com')
      expect(result).to contain_exactly(order_one)
    end

    it 'filters orders by status' do
      result = described_class.call(status: 'shipped')
      expect(result).to contain_exactly(order_one)
    end

    it 'filters orders by id' do
      result = described_class.call(id: order_two.id)
      expect(result).to contain_exactly(order_two)
    end

    it 'returns orders sorted by created_at in descending order' do
      result = described_class.call({})
      expect(result).to eq([order_two, order_one])
    end
  end
end
