# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendOrderConfirmationJob, type: :job do
  describe '#perform' do
    let(:order) { create(:order) }

    it 'sends order confirmation email' do
      expect do
        described_class.perform_later(order.id)
      end.to have_enqueued_job.with(order.id)
    end
  end
end
