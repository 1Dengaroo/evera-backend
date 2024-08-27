# frozen_string_literal: true

class ProductsController < ApplicationController
  def index
    @products = Product.where(active: true)
    render json: @products
  end

  def show
    @product = Product.find_by!(id: params[:id], active: true)
    render json: @product
  end

  def price_by_id
    @product = Product.find_by!(id: params[:id], active: true)
    render json: { price: @product.price }
  end

  def cart_total
    items = params.require(:items).map { |item| item.permit(:id, :quantity).to_h }
    @total = ProductsService::CalculateCartTotal.call(items)

    render json: { total: @total }
  end

  def front_page_products
    @products = Product.where(active: true).order(created_at: :desc).limit(4)
    render json: @products
  end
end
