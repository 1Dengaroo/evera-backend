# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    email { 'customer@example.com' }
    checkout_session_id { 'cs_test_123' }
    paid { false }
    subtotal { 1000 }
  end
end
