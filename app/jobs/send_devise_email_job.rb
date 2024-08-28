# frozen_string_literal: true

class SendDeviseEmailJob < ApplicationJob
  queue_as :default

  def perform(record, token)
    Devise::Mailer.reset_password_instructions(record, token).deliver_later
  end
end
