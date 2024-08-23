# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_items
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :checkout_session_id, presence: true
end
