# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsService::Base, type: :service do
  let(:response) { instance_double(SendGrid::Response, status_code: '200', body: '{}') }

  describe '.raise_error_when_fails' do
    context 'when response status code is successful' do
      it 'does not raise an error' do
        allow(response).to receive_messages(status_code: '200', body: '{}')
        expect { described_class.raise_error_when_fails(response:) }.not_to raise_error
      end
    end

    context 'when response status code is in error range' do
      let(:response) { instance_double(SendGrid::Response, status_code: '400', body: '{"errors": [{"message": "Invalid email"}]}') }

      it 'raises a NotificationsError' do
        allow(response).to receive_messages(status_code: '400', body: '{"errors": [{"message": "Invalid email"}]}')
        expect { described_class.raise_error_when_fails(response:) }.to raise_error(NotificationsService::NotificationsError, /Invalid email/)
      end
    end

    context 'when response body contains errors' do
      let(:response) { instance_double(SendGrid::Response, status_code: '200', body: '{"errors": [{"message": "Invalid email"}]}') }

      it 'raises a NotificationsError' do
        allow(response).to receive_messages(status_code: '200', body: '{"errors": [{"message": "Invalid email"}]}')
        expect { described_class.raise_error_when_fails(response:) }.to raise_error(NotificationsService::NotificationsError, /Invalid email/)
      end
    end
  end
end
