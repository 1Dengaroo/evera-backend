# frozen_string_literal: true

module CartsService
  class ValidateProduct
    def self.call(item)
      product = Product.find_by(id: item[:id])
      return { valid: false, status: :not_found, message: 'Product not found' } if product.nil?
      return { valid: false, status: :unprocessable_entity, message: 'Product is out of stock' } if product.quantity < item[:quantity].to_i
      return { valid: false, status: :unprocessable_entity, message: 'Quantity must be greater than 0' } if item[:quantity].to_i <= 0
      return { valid: false, status: :unprocessable_entity, message: 'Quantity must be less than 10' } if item[:quantity].to_i >= 10
      return { valid: false, status: :unprocessable_entity, message: 'Product is no longer active' } unless product.active
      return { valid: false, status: :unprocessable_entity, message: 'Product is not available in the selected size' } if product.sizes.exclude?(item[:size])

      { valid: true, message: 'Product is valid' }
    end
  end
end
