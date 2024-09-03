# frozen_string_literal: true

module CartsService
  class ValidateCart
    def self.call(items)
      items.each do |item|
        product = Product.find_by(id: item[:id])
        return { valid: false, status: :not_found } if product.nil?
        return { valid: false, status: :unprocessable_entity, message: 'Product is out of stock' } if product.quantity < item[:quantity]
        return { valid: false, status: :unprocessable_entity, message: 'Product is no longer active' } unless product.active
      end
      { valid: true }
    end
  end
end
