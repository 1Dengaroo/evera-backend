class Api::V1::OrdersController < ApplicationController
  require 'stripe'

  def create
    Stripe.api_key = ENV['STRIPE_API_KEY']

    begin 
      payment_intent = Stripe::PaymentIntent.create({
        amount: params[:amount].to_i,
        receipt_email: params[:email],
        currency: 'usd',
        automatic_payment_methods: {
          enabled: true,
        },
      })

      print payment_intent
      render json: { client_secret: payment_intent.client_secret }
    rescue Stripe::CardError => e
      render json: { error: e.message }, status: :payment_required
    rescue Stripe::InvalidRequestError => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end
