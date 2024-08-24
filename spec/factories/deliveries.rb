# frozen_string_literal: true

FactoryBot.define do
  factory :delivery do
    email { 'andy.deng@example.com' }
    status { 'manufacturing' }
    tracking_information { '123456789' }
    session_id { 'cs_1GqIC8XnYozEGLjpCz7iRjz8' }
    association :order
    association :address
  end
end
