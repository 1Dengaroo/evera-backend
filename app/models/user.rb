# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  has_many :orders, dependent: :nullify

  devise :database_authenticatable, :registerable, :recoverable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  attribute :admin, :boolean, default: false

  def send_reset_password_instructions
    token = set_reset_password_token
    SendDeviseEmailJob.perform_later(self, token)
  end
end
