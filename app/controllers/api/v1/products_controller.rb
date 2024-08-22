# frozen_string_literal: true

class Api::V1::ProductsController < ApplicationController
  def index
    @products = Product.all.filter(&:active)
    render json: @products
  end

  def show
    @product = Product.find(params[:id])
    render json: @product
  end

  def price_by_id
    @product = Product.find(params[:id])
    render json: { price: @product.price }
  end

  def cart_total
    @total = ProductsService::CalculateCartTotal.call(params[:items])

    render json: { total: @total }
  end
end
