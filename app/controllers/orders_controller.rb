# frozen_string_literal: true

class OrdersController < ApplicationController
  include UserStatus

  before_action :authenticate_user_status!, only: [:index]
  before_action :authenticate_admin_status!, only: %i[admin_index update]

  def create
    permitted_items = params.require(:items).map { |item| item.permit(:id, :quantity, :size).to_h }
    result = OrdersService::CreateCheckoutSession.new(user: current_user, items: permitted_items).call

    if result[:error]
      render json: { error: result[:error] }, status: result[:status]
    else
      render json: { session_id: result[:session_id], session_url: result[:session_url] }
    end
  rescue OrdersService::InvalidCartError => e
    render json: { error: e.message }, status: :bad_request
  end

  def index
    @orders = current_user.orders.where(paid: true)
      .includes(order_items: :product, delivery: :address)
      .order(created_at: :desc)
    render json: @orders.as_json(orders_json_options)
  end

  def update
    @order = OrdersService::UpdateOrder.call(order_id: params[:id], order_params: order_update_params)
    render json: @order.as_json(orders_json_options)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
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
      only: %i[id email paid subtotal amount_shipping amount_tax created_at updated_at],
      include: {
        order_items: {
          only: %i[product_id quantity size],
          include: {
            product: {
              only: %i[name price cover_image]
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
