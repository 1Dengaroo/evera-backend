# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :authenticate_admin!, only: %i[create edit update admin_index]

  def index
    @products = ProductsService::UserFilterProducts.call(params)
    render json: @products
  end

  def show
    @product = Product.find_by(id: params[:id], active: true)
    render json: @product
  end

  def price_by_id
    @product = Product.find_by(id: params[:id], active: true)
    if @product.nil?
      render json: { error: 'Product not found' }, status: :not_found
      return
    end
    render json: { price: @product.price }
  end

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

  def front_page_products
    @products = Product.where(active: true).order(created_at: :desc).limit(4)
    render json: @products
  end

  def similar_products
    @product = Product.find_by(id: params[:id])
    @products = ProductsService::SimilarProducts.call(@product)
    render json: @products
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def edit
    @product = Product.find_by!(id: params[:id])
    render json: @product
  end

  def update
    @product = Product.find_by(id: params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def admin_index
    @products = ProductsService::AdminFilterProducts.call(params)
    render json: @products
  end

  private

  def authenticate_admin!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user&.admin?
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :active, :product_type,
      :cover_image, :quantity, sizes: [], sub_images: []
    )
  end
end
