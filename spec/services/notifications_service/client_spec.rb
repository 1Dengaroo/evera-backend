# frozen_string_literal: true

require 'rails_helper'
require 'sendgrid-ruby'

RSpec.describe NotificationsService::Client, type: :service do
  let(:sendgrid_api) { instance_double(SendGrid::API) }
  let(:response) { instance_double(SendGrid::Response, status_code: '200', body: '{}') }
  let(:data) { { to: 'test@example.com', subject: 'Test Subject', content: 'Test Content' } }

  before do
    allow(SendGrid::API).to receive(:new).and_return(sendgrid_api)
    allow(sendgrid_api).to receive_message_chain(:client, :mail, :_, :post).and_return(response)
  end

  describe '.send_email' do
    it 'sends an email successfully' do
      allow(sendgrid_api.client.mail._('send')).to receive(:post).with(request_body: data).and_return(response)
      expect { described_class.send_email(data) }.not_to raise_error
    end

    context 'when SendGrid returns an error' do
      let(:response) { instance_double(SendGrid::Response, status_code: '400', body: '{"errors": [{"message": "Invalid email"}]}') }

      it 'raises a NotificationsError' do
        allow(sendgrid_api.client.mail._('send')).to receive(:post).with(request_body: data).and_return(response)
        expect { described_class.send_email(data) }.to raise_error(NotificationsService::NotificationsError, /Invalid email/)
      end
    end
  end
end
