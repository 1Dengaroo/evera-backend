# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :authenticate_admin!, only: %i[create edit update admin_index]

  def index
    @products = Product.where(active: true)
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
    @total = ProductsService::CalculateCartTotal.call(items)
    render json: { total: @total }
  end

  def validate_cart
    items = params.require(:items).map { |item| item.permit(:id, :quantity).to_h }
    items.each do |item|
      product = Product.find_by(id: item[:id])
      if product.nil? || product.quantity < item[:quantity] || !product.active
        render json: { valid: false }, status: :not_found
        break
      end
    end
    render json: { valid: true }
  end

  def validate_product
    @item = params.require(:item).permit(:id, :quantity).to_h
    @product = Product.find_by(id: @item[:id])
    if @product.nil?
      render json: { valid: false, message: 'Product not found' }, status: :not_found
    elsif @product.quantity < @item[:quantity]
      render json: { valid: false, message: 'Product is out of stock' }, status: :unprocessable_entity
    elsif !@product.active
      render json: { valid: false, message: 'Product is no longer active' }, status: :unprocessable_entity
    else
      render json: { valid: true, message: 'Product is valid' }
    end
  end

  def front_page_products
    @products = Product.where(active: true).order(created_at: :desc).limit(4)
    render json: @products
  end

  def create
    @product = Product.new(product_params)
    @product.quantity = 9_999_999
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
    @products = Product.all
    @products = @products.where(active: params[:active]) if params[:active].present?
    @products = @products.where('name ILIKE ?', "%#{params[:name]}%") if params[:name].present?

    if params[:created_at].present?
      start_date = begin
        Date.parse(params[:created_at][:start_date])
      rescue StandardError
        nil
      end
      end_date = begin
        Date.parse(params[:created_at][:end_date])
      rescue StandardError
        nil
      end
      @products = @products.where(created_at: start_date..end_date) if start_date && end_date
    end

    if params[:sort_by_date].present?
      direction = params[:sort_by_date] == 'desc' ? :desc : :asc
      @products = @products.order(created_at: direction)
    end

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
