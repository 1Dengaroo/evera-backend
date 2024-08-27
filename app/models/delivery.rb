# frozen_string_literal: true

class Delivery < ApplicationRecord
  belongs_to :order
  belongs_to :address

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true
  validates :session_id, presence: true, uniqueness: true

  accepts_nested_attributes_for :address
end
