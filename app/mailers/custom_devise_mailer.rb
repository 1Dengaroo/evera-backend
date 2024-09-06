# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  default from: 'no-reply@everafashion.com'

  def reset_password_instructions(record, token, opts = {})
    super
  end
end
