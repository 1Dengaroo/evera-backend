# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  def create
    permitted_items = params.require(:items).map { |item| item.permit(:id, :quantity).to_h }
    amount_in_cents = (ProductsService::CalculateCartTotal.call(permitted_items) * 100).to_i
    email = 'example@email.com'

    begin
      session = OrdersService::StripePayment.new(email:, items: permitted_items).create_checkout_session

      OrdersService::CreateOrder.call(
        email:,
        checkout_session_id: session.id,
        amount_in_cents:,
        items: permitted_items
      )

      render json: { session_id: session.id }
    rescue Stripe::StripeError => e
      Rails.logger.debug(e)
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Product not found: #{e.message}" }, status: :not_found
    end
  end
end
