# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  it 'is valid with valid attributes' do
    order_item = build(:order_item)
    expect(order_item).to be_valid
  end

  it 'is not valid without an order' do
    order_item = build(:order_item, order: nil)
    expect(order_item).not_to be_valid
  end

  it 'is valid without a size' do
    order_item = build(:order_item, size: nil)
    expect(order_item).to be_valid
  end

  it 'is valid with a size' do
    order_item = build(:order_item, size: 'M')
    expect(order_item).to be_valid
  end

  it 'is not valid without a product' do
    order_item = build(:order_item, product: nil)
    expect(order_item).not_to be_valid
  end

  it 'is not valid without a quantity' do
    order_item = build(:order_item, quantity: nil)
    expect(order_item).not_to be_valid
  end

  it 'is not valid with a quantity less than 1' do
    order_item = build(:order_item, quantity: 0)
    expect(order_item).not_to be_valid
  end

  it 'belongs to an order and a product' do
    order_item = create(:order_item)
    expect(order_item.order).to be_an_instance_of(Order)
    expect(order_item.product).to be_an_instance_of(Product)
  end
end
