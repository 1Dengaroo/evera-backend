# frozen_string_literal: true

module OrdersService
  class CreateOrder
    def self.call(checkout_session_id:, subtotal:, items:)
      order = Order.create!(checkout_session_id:, paid: false, subtotal:)

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
