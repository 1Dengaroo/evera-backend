# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :deliveries, dependent: :destroy

  validates :city, :country, :line1, :postal_code, :state, :name, presence: true
end
