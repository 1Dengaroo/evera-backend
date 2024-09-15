# frozen_string_literal: true

module CartsService
  class CalculateCartTotal
    def self.call(items)
      total = 0
      items.each do |item|
        product = Product.find_by(id: item['id'], active: true)
        next unless product

        total += product.price * item['quantity']
      end
      total
    end
  end
end
