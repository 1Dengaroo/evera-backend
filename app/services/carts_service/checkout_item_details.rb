# frozen_string_literal: true

module CartsService
  class CheckoutItemDetails
    def self.call(items)
      items.map do |item|
        product = Product.find_by(id: item['id'], active: true)
        if product.nil?
          {
            id: item['id'],
            size: item['size'],
            price: 0,
            isValid: false,
            validationMessage: 'Product not found.'
          }
        else
          validation_result = CartsService::ValidateProduct.call(item)

          {
            id: item['id'],
            size: item['size'],
            price: product.price,
            isValid: validation_result[:valid],
            validationMessage: validation_result[:message]
          }
        end
      end
    end
  end
end
