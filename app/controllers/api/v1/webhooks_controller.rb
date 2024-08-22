class Api::V1::WebhooksController < ApplicationController
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    case event['type']
    when 'payment_intent.succeeded'
      payment_intent = event['data']['object']

      # Find the order by payment intent ID
      order = Order.find_by(payment_intent_id: payment_intent.id)
      if order
        order.update(completed: true)
      end

    # Handle other event types...
    else
      puts "Unhandled event type: #{event['type']}"
    end

    render json: { message: 'Success' }, status: 200
  end
end
