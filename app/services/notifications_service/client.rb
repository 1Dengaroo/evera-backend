# frozen_string_literal: true

module NotificationsService
  class Client < Base
    def self.send_email(data)
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      response = sg.client.mail._('send').post(request_body: data)

      raise_error_when_fails(response:)
    end
  end
end
