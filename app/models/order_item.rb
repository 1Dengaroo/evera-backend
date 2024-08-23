# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order, primary_key: :id
  belongs_to :product
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
