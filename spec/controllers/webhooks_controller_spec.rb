# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST #stripe' do
    let(:valid_signature) { 'valid_signature' }
    let(:invalid_signature) { 'invalid_signature' }
    let(:payload) { { id: 'evt_123', type: 'checkout.session.completed' }.to_json }
    let(:headers) { { 'HTTP_STRIPE_SIGNATURE' => valid_signature } }
    let(:invalid_headers) { { 'HTTP_STRIPE_SIGNATURE' => invalid_signature } }
    let(:event) { JSON.parse(payload) }

    before do
      allow(Stripe::Webhook).to receive(:construct_event)
        .with(payload, valid_signature, ENV['STRIPE_ENDPOINT_SECRET'])
        .and_return(event)

      allow(Stripe::Webhook).to receive(:construct_event)
        .with(payload, invalid_signature, ENV['STRIPE_ENDPOINT_SECRET'])
        .and_raise(Stripe::SignatureVerificationError.new('Invalid signature', 'sig_error'))
    end

    context 'with valid signature' do
      before do
        request.headers.merge!(headers)
      end

      it 'calls the appropriate service when the event is payment_intent.succeeded' do
        allow(WebhooksService::Stripe).to receive(:cs_completed)

        post :stripe, body: payload

        expect(WebhooksService::Stripe).to have_received(:cs_completed).with(event)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Success')
      end

      it 'returns bad_request for an unknown event type' do
        unknown_event = { 'type' => 'unknown_event' }
        allow(Stripe::Webhook).to receive(:construct_event)
          .with(payload, valid_signature, ENV['STRIPE_ENDPOINT_SECRET'])
          .and_return(unknown_event)

        post :stripe, body: payload

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Invalid event type')
      end
    end

    context 'with invalid signature' do
      it 'returns a bad request status' do
        request.headers.merge!(invalid_headers)
        post :stripe, body: payload

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Invalid signature')
      end
    end

    context 'with invalid payload' do
      let(:invalid_payload) { 'invalid_json' }

      it 'returns a bad request status' do
        request.headers.merge!(headers)

        allow(Stripe::Webhook).to receive(:construct_event)
          .with(invalid_payload, valid_signature, ENV['STRIPE_ENDPOINT_SECRET'])
          .and_raise(JSON::ParserError.new('Invalid payload'))

        post :stripe, body: invalid_payload

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Invalid payload')
      end
    end
  end
end
