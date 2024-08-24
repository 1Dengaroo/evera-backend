FactoryBot.define do
  factory :delivery do
    email { "MyString" }
    status { "MyString" }
    tracking_information { "MyString" }
    session_id { "MyString" }
    order { nil }
    address { nil }
  end
end
