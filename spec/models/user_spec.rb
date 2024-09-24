# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:orders).dependent(:nullify) }
    it { is_expected.to have_one(:phone_number).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it 'is invalid without a password' do
      user = described_class.new(email: 'test@example.com')
      expect(user).not_to(be_valid)
      expect(user.errors[:password]).to include("can't be blank")
    end
  end

  describe 'Devise settings' do
    it 'includes JTIMatcher for JWT revocation strategy' do
      expect(described_class.devise_modules).to include(:jwt_authenticatable)
      expect(described_class.jwt_revocation_strategy).to eq(described_class)
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string) }
    it { is_expected.to have_db_column(:jti).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_token).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index(:jti).unique(true) }
    it { is_expected.to have_db_index(:reset_password_token).unique(true) }
  end
end
