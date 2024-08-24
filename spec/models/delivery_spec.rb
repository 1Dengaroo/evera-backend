# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Delivery, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      order = create(:order)
      address = create(:address)
      delivery = described_class.new(
        email: 'andy.deng@example.com',
        status: 'manufacturing',
        session_id: 'cs_1GqIC8XnYozEGLjpCz7iRjz8',
        order:,
        address:
      )
      expect(delivery).to be_valid
    end

    it 'is not valid without an email' do
      delivery = described_class.new(email: nil)
      expect(delivery).not_to be_valid
      expect(delivery.errors[:email]).to include("can't be blank")
    end

    it 'is not valid without a status' do
      delivery = described_class.new(status: nil)
      expect(delivery).not_to be_valid
      expect(delivery.errors[:status]).to include("can't be blank")
    end

    it 'is not valid without a session_id' do
      delivery = described_class.new(session_id: nil)
      expect(delivery).not_to be_valid
      expect(delivery.errors[:session_id]).to include("can't be blank")
    end

    it 'is not valid with a duplicate session_id' do
      create(:delivery, session_id: 'cs_1GqIC8XnYozEGLjpCz7iRjz8')
      new_delivery = described_class.new(session_id: 'cs_1GqIC8XnYozEGLjpCz7iRjz8')
      expect(new_delivery).not_to be_valid
      expect(new_delivery.errors[:session_id]).to include('has already been taken')
    end

    it 'is not valid with an invalid email format' do
      delivery = described_class.new(email: 'invalid-email')
      expect(delivery).not_to be_valid
      expect(delivery.errors[:email]).to include('is invalid')
    end
  end

  describe 'associations' do
    it 'belongs to an order' do
      association = described_class.reflect_on_association(:order)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to an address' do
      association = described_class.reflect_on_association(:address)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'default status' do
    let(:order) { create(:order) }
    let(:address) { create(:address) }
    let(:delivery) { create(:delivery, order:, address:) }

    it 'is manufacturing' do
      expect(delivery.status).to eq('manufacturing')
    end
  end
end
