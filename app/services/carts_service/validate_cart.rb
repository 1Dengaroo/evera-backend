# frozen_string_literal: true

module CartsService
  class ValidateCart
    def self.call(items)
      items.each do |item|
        result = CartsService::ValidateProduct.call(item)
        return result unless result[:valid]
      end
      { valid: true }
    end
  end
end
