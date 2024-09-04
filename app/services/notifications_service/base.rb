# frozen_string_literal: true

module NotificationsService
  class NotificationsError < StandardError; end

  # https://docs.sendgrid.com/api-reference/how-to-use-the-sendgrid-v3-api/errors
  SEND_GRID_ERRORS_CODE = %w[400 401 406 429 500].freeze
  BASE_EMAIL = 'denga323@gmail.com'
  BASE_NAME = 'Evera'

  class Base
    def self.raise_error_when_fails(response:)
      return unless response.status_code.in?(SEND_GRID_ERRORS_CODE) || response.body.include?('errors')

      raise NotificationsError, response.body
    end
  end
end
