# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    quantity { 1 }
  end
end
