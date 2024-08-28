# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendDeviseEmailJob, type: :job do
  describe '#perform' do
    let(:user) { create(:user) }

    it 'sends devise email' do
      expect do
        described_class.perform_later(user.id, 'reset_password_instructions')
      end.to have_enqueued_job.with(user.id, 'reset_password_instructions')
    end
  end
end
