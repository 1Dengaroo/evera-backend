# frozen_string_literal: true

module OrdersService
  class StripePayment
    def initialize(email:, items:)
      @email = email
      @items = items
      Stripe.api_key = ENV['STRIPE_API_KEY']
    end

    def create_checkout_session
      root_url = "#{ENV['CLIENT_APP_PROTOCOL']}://#{ENV['CLIENT_APP_HOST']}"
      line_items = @items.map do |item|
        product = Product.find_by(id: item['id'], active: true)
        raise StripeError, 'Product not found' if product.nil?

        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: product.name
            },
            unit_amount: (product.price * 100).to_i
          },
          quantity: item['quantity']
        }
      end

      Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items:,
        mode: 'payment',
        success_url: "#{root_url}/success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{root_url}/cancel",
        customer_email: @email
      })
    end

    class StripeError < StandardError; end
  end
end
