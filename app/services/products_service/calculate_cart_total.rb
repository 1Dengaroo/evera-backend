# frozen_string_literal: true

module ProductsService
  class CalculateCartTotal
    def self.call(items)
      total = 0
      items.each do |item|
        product = Product.find(item['id'])
        total += product.price * item['quantity']
      end
      total
    end
  end
end
