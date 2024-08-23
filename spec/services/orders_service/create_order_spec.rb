# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersService::CreateOrder, type: :service do
  let(:checkout_session_id) { 'cs_123' }
  let(:amount_in_cents) { 5000 }
  let(:product_one) { create(:product, price: 10.00) }
  let(:product_two) { create(:product, price: 20.00) }
  let(:items) do
    [
      { 'id' => product_one.id, 'quantity' => 2 },
      { 'id' => product_two.id, 'quantity' => 1 }
    ]
  end

  context 'when all products are found' do
    it 'creates an order and order items' do
      expect do
        described_class.call(
          checkout_session_id:,
          amount_in_cents:,
          items:
        )
      end.to change(Order, :count).by(1)
        .and change(OrderItem, :count).by(2)

      order = Order.last
      expect(order.email).to be_nil
      expect(order.checkout_session_id).to eq(checkout_session_id)
      expect(order.price).to eq(amount_in_cents)
      expect(order.completed).to be_falsey

      order_item1 = order.order_items.find_by(product: product_one)
      order_item2 = order.order_items.find_by(product: product_two)

      expect(order_item1.quantity).to eq(2)
      expect(order_item2.quantity).to eq(1)
    end
  end

  context 'when a product is not found' do
    it 'raises ActiveRecord::RecordNotFound' do
      invalid_items = [{ 'id' => 999, 'quantity' => 1 }]

      expect do
        described_class.call(
          checkout_session_id:,
          amount_in_cents:,
          items: invalid_items
        )
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
