# frozen_string_literal: true

module OrdersService
  class CreateOrder
    def self.call(email:, checkout_session_id:, amount_in_cents:, items:)
      order = Order.create!(email:, checkout_session_id:, completed: false, price: amount_in_cents)

      items.each do |item|
        product = Product.find(item['id'])
        OrderItem.create!(
          order:,
          product:,
          quantity: item['quantity']
        )
      end

      order
    end
  end
end
