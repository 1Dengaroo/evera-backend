# frozen_string_literal: true

class Api::V1::WebhooksController < ApplicationController
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
    rescue JSON::ParserError
      return render json: { error: 'Invalid payload' }, status: :bad_request
    rescue Stripe::SignatureVerificationError
      return render json: { error: 'Invalid signature' }, status: :bad_request
    end

    case event['type']
    when 'checkout.session.completed'
      WebhooksService::Stripe.cs_completed(event)
    else
      return render json: { error: 'Invalid event type' }, status: :bad_request
    end

    render json: { message: 'Success' }, status: :ok
  end
end
