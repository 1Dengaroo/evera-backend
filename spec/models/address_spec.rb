# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      address = described_class.new(
        city: 'Hillsborough Township',
        country: 'US',
        line1: '8 Bush Road',
        postal_code: '08844',
        state: 'NJ',
        name: 'Andy Deng'
      )
      expect(address).to be_valid
    end

    it 'is not valid without a city' do
      address = described_class.new(city: nil)
      expect(address).not_to be_valid
      expect(address.errors[:city]).to include("can't be blank")
    end

    it 'is not valid without a country' do
      address = described_class.new(country: nil)
      expect(address).not_to be_valid
      expect(address.errors[:country]).to include("can't be blank")
    end

    it 'is not valid without line1' do
      address = described_class.new(line1: nil)
      expect(address).not_to be_valid
      expect(address.errors[:line1]).to include("can't be blank")
    end

    it 'is not valid without a postal_code' do
      address = described_class.new(postal_code: nil)
      expect(address).not_to be_valid
      expect(address.errors[:postal_code]).to include("can't be blank")
    end

    it 'is not valid without a state' do
      address = described_class.new(state: nil)
      expect(address).not_to be_valid
      expect(address.errors[:state]).to include("can't be blank")
    end

    it 'is not valid without a name' do
      address = described_class.new(name: nil)
      expect(address).not_to be_valid
      expect(address.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many deliveries' do
      association = described_class.reflect_on_association(:deliveries)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end
end
