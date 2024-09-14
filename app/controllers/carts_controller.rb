# frozen_string_literal: true

class CartsController < ApplicationController
  def cart_total
    items = params.require(:items).map { |item| item.permit(:id, :quantity).to_h }
    unless CartsService::ValidateCart.call(items)
      render json: { error: 'Invalid cart' }, status: :bad_request
      return
    end

    @total = CartsService::CalculateCartTotal.call(items)
    render json: { total: @total }
  end

  def validate_cart
    items = params.require(:items).map { |item| item.permit(:id, :quantity, :size).to_h }
    result = CartsService::ValidateCart.call(items)

    if result[:valid]
      render json: { valid: true }
    else
      render json: { valid: false, message: result[:message] }, status: result[:status]
    end
  end

  def validate_product
    @item = params.require(:item).permit(:id, :quantity, :size).to_h
    result = CartsService::ValidateProduct.call(@item)

    render json: { valid: result[:valid], message: result[:message] }, status: result[:status]
  end

  def cart_item_details
    items = params.require(:items).map { |item| item.permit(:id, :quantity, :size).to_h }

    item_details = CartsService::CheckoutItemDetails.call(items)
    total = CartsService::CalculateCartTotal.call(items)
    cart_is_valid = item_details.all? { |detail| detail[:isValid] }

    render json: {
      itemDetails: item_details,
      total:,
      cartIsValid: cart_is_valid
    }
  end
end
