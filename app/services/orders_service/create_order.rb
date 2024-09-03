# frozen_string_literal: true

module OrdersService
  class CreateOrder
    def self.call(checkout_session_id:, amount_in_cents:, items:)
      order = Order.create!(checkout_session_id:, paid: false, price: amount_in_cents)

      items.each do |item|
        product = Product.find(item['id'])
        OrderItem.create!(
          order:,
          product:,
          quantity: item['quantity'],
          size: item['size']
        )
      end

      order
    end
  end
end
