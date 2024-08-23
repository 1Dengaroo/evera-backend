# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_items
  validates :checkout_session_id, presence: true
end
