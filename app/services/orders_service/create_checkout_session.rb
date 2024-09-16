# frozen_string_literal: true

module OrdersService
  class CreateCheckoutSession
    def initialize(user:, items:)
      @user = user
      @items = items
    end

    def call
      validate_cart
      create_checkout_session
      create_order
      update_order_with_user

      { session_id: @session.id, session_url: @session.url }
    rescue Stripe::StripeError => e
      { error: e.message, status: :bad_request }
    rescue ActiveRecord::RecordNotFound => e
      { error: "Product not found: #{e.message}", status: :not_found }
    end

    private

    def validate_cart
      return if CartsService::ValidateCart.call(@items)[:valid]

      raise InvalidCartError, 'Invalid cart'
    end

    def create_checkout_session
      @session = OrdersService::StripePayment.new(email: @user&.email, items: @items).create_checkout_session
    end

    def create_order
      @order = OrdersService::CreateOrder.call(
        checkout_session_id: @session.id,
        subtotal: CartsService::CalculateCartTotal.call(@items),
        items: @items
      )
    end

    def update_order_with_user
      @order.update!(user: @user) if @user
    end
  end

  class InvalidCartError < StandardError; end
end
