# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :authenticate_admin!, only: %i[admin_index update]

  def create
    permitted_items = params.require(:items).map { |item| item.permit(:id, :quantity, :size).to_h }

    unless CartsService::ValidateCart.call(permitted_items)
      render json: { error: 'Invalid cart' }, status: :bad_request
      return
    end

    total = CartsService::CalculateCartTotal.call(permitted_items)

    begin
      session = OrdersService::StripePayment.new(email: current_user&.email, items: permitted_items).create_checkout_session
      order = OrdersService::CreateOrder.call(
        checkout_session_id: session.id,
        total:,
        items: permitted_items
      )

      order.update!(user: current_user) if current_user

      render json: { session_id: session.id }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Product not found: #{e.message}" }, status: :not_found
    end
  end

  def index
    @orders = current_user.orders.where(paid: true).order(created_at: :desc)
    render json: @orders.as_json(orders_json_options)
  end

  def track_order
    @order = Order.find_by!(id: params[:id])
    render json: @order.as_json(orders_json_options)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Order not found' }, status: :not_found
  end

  def admin_index
    @orders = OrdersService::FilterOrders.call(params)
    render json: @orders.as_json(orders_json_options)
  end

  def update
    @order = OrdersService::UpdateOrder.call(order_id: params[:id], order_params: order_update_params)
    render json: @order.as_json(orders_json_options)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  def success
    @order = Order.find_by(checkout_session_id: params[:session_id])
    if @order
      render json: @order.as_json(orders_json_options)
    else
      render json: { error: 'Order not found' }, status: :not_found
    end
  end

  private

  def orders_json_options
    {
      only: %i[id email paid price created_at updated_at],
      include: {
        order_items: {
          only: %i[product_id quantity size],
          include: {
            product: {
              only: %i[name price]
            }
          }
        },
        delivery: {
          only: %i[email status tracking_information created_at updated_at],
          include: {
            address: {
              only: %i[name line1 line2 city state postal_code country]
            }
          }
        }
      }
    }
  end

  def authenticate_admin!
    render json: { error: 'Unauthorized access' }, status: :forbidden unless !current_user.nil? && current_user.admin?
  end

  def order_update_params
    params.require(:order).permit(
      delivery_attributes: [
        :status,
        :tracking_information,
        { address_attributes: %i[
          name
          line1
          line2
          city
          state
          postal_code
          country
        ] }
      ]
    )
  end
end
