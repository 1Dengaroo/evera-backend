# frozen_string_literal: true

module OrdersService
  class StripePayment
    class StripeError < StandardError; end

    def initialize(items:, email:)
      @items = items
      @email = email
      Stripe.api_key = ENV['STRIPE_API_KEY']
    end

    def create_checkout_session
      root_url = client_app_url
      line_items = build_line_items

      Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items:,
        mode: 'payment',
        customer_email: @email,
        automatic_tax: { enabled: true },
        success_url: "#{root_url}/orders/success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{root_url}/orders/cancel",
        billing_address_collection: 'required',
        shipping_address_collection:,
        shipping_options:
      })
    rescue Stripe::StripeError => e
      raise StripeError, e.message
    end

    private

    def build_line_items
      @items.map do |item|
        product = Product.find_by(id: item['id'], active: true)
        raise StripeError, 'Product not found' if product.nil?

        product_name = item['size'].present? ? "#{product.name} (#{item['size']})" : product.name

        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: product_name
            },
            unit_amount: product.price
          },
          quantity: item['quantity']
        }
      end
    end

    def client_app_url
      "#{ENV['CLIENT_APP_PROTOCOL']}://#{ENV['CLIENT_APP_HOST']}"
    end

    def shipping_address_collection
      {
        allowed_countries: %w[US CA]
      }
    end

    def shipping_options
      [
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 0,
              currency: 'usd'
            },
            display_name: 'Free Shipping',
            delivery_estimate: {
              minimum: { unit: 'business_day', value: 5 },
              maximum: { unit: 'business_day', value: 10 }
            }
          }
        },
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 1500,
              currency: 'usd'
            },
            display_name: 'Expedited Shipping',
            delivery_estimate: {
              minimum: { unit: 'business_day', value: 2 },
              maximum: { unit: 'business_day', value: 4 }
            }
          }
        }
      ]
    end
  end
end
