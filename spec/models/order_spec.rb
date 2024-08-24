# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'is valid with valid attributes' do
    order = build(:order)
    expect(order).to be_valid
  end

  it 'is valid without an email' do
    order = build(:order, email: nil)
    expect(order).to be_valid
  end

  it 'is not valid without a checkout_session_id' do
    order = build(:order, checkout_session_id: nil)
    expect(order).not_to be_valid
  end

  it 'has many order_items' do
    order = create(:order)
    product = create(:product)
    order_item1 = create(:order_item, order:, product:)
    order_item2 = create(:order_item, order:, product:)

    expect(order.order_items).to include(order_item1, order_item2)
  end

  it 'has one delivery' do
    order = create(:order)
    address = create(:address)
    delivery = create(:delivery, order:, address:)

    expect(order.delivery).to eq(delivery)
  end

  it 'destroys associated delivery when order is destroyed' do
    order = create(:order)
    address = create(:address)
    create(:delivery, order:, address:)

    expect { order.destroy }.to change(Delivery, :count).by(-1)
  end
end
