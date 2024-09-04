# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendOrderConfirmationJob, type: :job do
  let(:order) { create(:order) }
  let(:email) { order.email }

  before do
    allow(NotificationsService::Order::OrderConfirmation).to receive(:send)
  end

  describe '#perform_later' do
    it 'queues the job' do
      expect do
        described_class.perform_later(email, order.id)
      end.to have_enqueued_job(described_class).with(email, order.id).on_queue('default')
    end
  end

  describe '#perform' do
    it 'calls the service' do
      described_class.perform_now(email, order.id)
      expect(NotificationsService::Order::OrderConfirmation).to have_received(:send).with(to: email, order:)
    end
  end
end
