# frozen_string_literal: true

class ProductsController < ApplicationController
  include UserStatus

  before_action :authenticate_admin_status!, only: %i[create edit update admin_index]
  before_action :set_user_product, only: %i[show price_by_id similar_products]
  before_action :set_admin_product, only: %i[edit update]

  def index
    @products = ProductsService::UserFilterProducts.call(params)
    render json: @products
  end

  def show
    render json: @product
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
    render json: @product
  end

  def update
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

  def price_by_id
    render json: { price: @product.price }
  end

  def front_page_products
    @products = Product.where(active: true).order(created_at: :desc).limit(4)
    render json: @products
  end

  def similar_products
    @products = ProductsService::SimilarProducts.call(@product)
    render json: @products
  end

  private

  def set_user_product
    @product = Product.find_by(id: params[:id], active: true)
    render json: { error: 'Product not found' }, status: :not_found if @product.nil?
  end

  def set_admin_product
    @product = Product.find_by(id: params[:id])
    render json: { error: 'Product not found' }, status: :not_found if @product.nil?
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :active, :product_type,
      :cover_image, :quantity, sizes: [], sub_images: []
    )
  end
end
