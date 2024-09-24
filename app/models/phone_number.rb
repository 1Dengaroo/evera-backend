# frozen_string_literal: true

class PhoneNumber < ApplicationRecord
  belongs_to :user

  phony_normalize :number, default_country_code: 'US'

  validates :number, phony_plausible: true, allow_blank: true
end
