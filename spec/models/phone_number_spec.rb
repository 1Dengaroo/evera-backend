# frozen_string_literal: true

# spec/models/phone_number_spec.rb
require 'rails_helper'

RSpec.describe PhoneNumber, type: :model do
  it 'validates phone number correctly' do
    user = create(:user)

    valid_phone = described_class.new(number: '+14155552671', user:)
    expect(valid_phone).to be_valid

    valid_phone = described_class.new(number: '4155552671', user:)
    expect(valid_phone).to be_valid

    valid_phone = described_class.new(number: '415-555-2671', user:)
    expect(valid_phone).to be_valid

    valid_phone = described_class.new(number: '', user:)
    expect(valid_phone).to be_valid

    valid_phone = described_class.new(number: nil, user:)
    expect(valid_phone).to be_valid

    invalid_phone = described_class.new(number: '123', user:)
    expect(invalid_phone).not_to(be_valid)

    invalid_phone = described_class.new(number: 'invalid', user:)
    expect(invalid_phone).not_to(be_valid)
  end
end
