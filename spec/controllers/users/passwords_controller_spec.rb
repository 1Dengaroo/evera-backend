# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :controller do
  let(:devise_mapping) { Devise.mappings[:user] }
  let(:user) { create(:user) }

  before do
    request.env['devise.mapping'] = devise_mapping
  end

  describe 'POST #create' do
    context 'when the email exists' do
      it 'sends reset password instructions and returns a success message' do
        allow(user).to receive(:send_reset_password_instructions).and_return(true)
        allow(User).to receive(:find_by).with(email: user.email).and_return(user)

        post :create, params: { email: user.email }, format: :json

        expect(user).to have_received(:send_reset_password_instructions)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('You will receive an email with instructions on how to reset your password in a few minutes.')
      end
    end

    context 'when the email does not exist' do
      it 'returns a not found error' do
        allow(User).to receive(:find_by).with(email: 'nonexistent@example.com').and_return(nil)

        post :create, params: { email: 'nonexistent@example.com' }, format: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Email not found')
      end
    end
  end

  describe 'PUT #update' do
    let(:reset_token) { 'valid_reset_token' }
    let(:reset_password_params) do
      ActionController::Parameters.new(
        reset_password_token: reset_token,
        password: 'newpassword',
        password_confirmation: 'newpassword'
      ).permit(:reset_password_token, :password, :password_confirmation)
    end

    context 'with valid token and passwords' do
      it 'resets the password and returns a success message' do
        allow(User).to receive(:reset_password_by_token).with(reset_password_params).and_return(user)
        allow(user).to receive(:errors).and_return(ActiveModel::Errors.new(user))

        put :update, params: { user: reset_password_params }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Password has been reset successfully.')
      end
    end

    context 'with invalid token or passwords' do
      it 'returns an error message for invalid token' do
        invalid_params = ActionController::Parameters.new(
          reset_password_token: 'invalid_token',
          password: 'newpassword',
          password_confirmation: 'newpassword'
        ).permit(:reset_password_token, :password, :password_confirmation)

        invalid_user = build_stubbed(:user)
        invalid_user.errors.add(:reset_password_token, 'is invalid')

        allow(User).to receive(:reset_password_by_token).with(invalid_params).and_return(invalid_user)

        put :update, params: { user: invalid_params }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include('Reset password token is invalid')
      end

      it 'returns an error if password confirmation does not match' do
        mismatch_params = ActionController::Parameters.new(
          reset_password_token: reset_token,
          password: 'newpassword',
          password_confirmation: 'mismatch'
        ).permit(:reset_password_token, :password, :password_confirmation)

        user_with_errors = build_stubbed(:user)
        user_with_errors.errors.add(:password_confirmation, "doesn't match Password")

        allow(User).to receive(:reset_password_by_token).with(mismatch_params).and_return(user_with_errors)

        put :update, params: { user: mismatch_params }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
