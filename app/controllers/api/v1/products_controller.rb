# frozen_string_literal: true

class Api::V1::ProductsController < ApplicationController
  def index
    @products = Product.all
    render json: @products
  end

  def show
    @product = Product.find(params[:id])
    render json: @product
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product
    else
      render json: { error: 'Unable to create product.' }, status: :bad_request
    end
  end

  def product_params
    params.require(:product).permit(:name, :price)
  end
end
