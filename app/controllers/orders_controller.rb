# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def create
    permitted_items = params.require(:items).map { |item| item.permit(:id, :quantity).to_h }
    amount_in_cents = (ProductsService::CalculateCartTotal.call(permitted_items) * 100).to_i

    begin
      session = OrdersService::StripePayment.new(items: permitted_items).create_checkout_session
      order = OrdersService::CreateOrder.call(
        checkout_session_id: session.id,
        amount_in_cents:,
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

    render json: @orders.as_json(
      only: %i[id email paid price created_at updated_at],
      include: {
        order_items: {
          only: %i[product_id quantity],
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
    )
  end
end
