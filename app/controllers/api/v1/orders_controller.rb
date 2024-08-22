# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  require 'stripe'

  def create
    Stripe.api_key = ENV['STRIPE_API_KEY']

    amount_in_cents = (ProductsService::CalculateCartTotal.call(params[:items]) * 100).to_i

    begin
      payment_intent = Stripe::PaymentIntent.create({
        amount: amount_in_cents,
        receipt_email: 'b@b.com',
        currency: 'usd',
        automatic_payment_methods: {
          enabled: true
        }
      })

      render json: { client_secret: payment_intent.client_secret }
    rescue Stripe::CardError => e
      render json: { error: e.message }, status: :payment_required
    rescue Stripe::InvalidRequestError => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end
