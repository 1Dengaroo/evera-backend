# frozen_string_literal: true

module CartsService
  class ValidateProduct
    def self.call(item)
      product = Product.find_by(id: item[:id])
      if product.nil?
        { valid: false, status: :not_found, message: 'Product not found' }
      elsif product.quantity < item[:quantity]
        { valid: false, status: :unprocessable_entity, message: 'Product is out of stock' }
      elsif !product.active
        { valid: false, status: :unprocessable_entity, message: 'Product is no longer active' }
      else
        { valid: true, message: 'Product is valid' }
      end
    end
  end
end
