# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  has_many :orders, dependent: :nullify
  has_one :phone_number, dependent: :destroy

  devise :database_authenticatable, :registerable, :recoverable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  attribute :admin, :boolean, default: false
  accepts_nested_attributes_for :phone_number

  def send_reset_password_instructions
    token = set_reset_password_token
    SendDeviseEmailJob.perform_later(self, token)
  end
end
