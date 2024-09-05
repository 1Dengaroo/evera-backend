# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminOrderConfirmationJob, type: :job do
  let(:order) { create(:order, paid: true) }

  before do
    allow(NotificationsService::Order::AdminOrderConfirmation).to receive(:send)
  end

  describe '#perform_later' do
    it 'queues the job' do
      expect do
        described_class.perform_later(order.id)
      end.to have_enqueued_job(described_class).with(order.id).on_queue('default')
    end
  end

  describe '#perform' do
    it 'calls the service' do
      described_class.perform_now(order.id)
      expect(NotificationsService::Order::AdminOrderConfirmation).to have_received(:send).with(order:)
    end
  end
end
