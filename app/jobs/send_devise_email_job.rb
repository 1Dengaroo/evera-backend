# frozen_string_literal: true

class SendDeviseEmailJob < ApplicationJob
  queue_as :default

  def perform(record, token)
    CustomDeviseMailer.reset_password_instructions(record, token, from: 'no-reply@everafashion.com').deliver_later
  end
end
