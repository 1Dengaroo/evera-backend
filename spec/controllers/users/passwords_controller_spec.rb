# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :controller do
  let(:devise_mapping) { Devise.mappings[:user] }

  before do
    request.env['devise.mapping'] = devise_mapping
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    context 'when the email exists' do
      it 'sends reset password instructions and returns a success message' do
        post :create, params: { email: user.email }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('You will receive an email with instructions on how to reset your password in a few minutes.')
      end
    end

    context 'when the email does not exist' do
      it 'returns a not found error' do
        post :create, params: { email: 'nonexistent@example.com' }, format: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Email not found')
      end
    end
  end

  describe 'PUT #update' do
    let(:user) { create(:user) }
    let(:reset_token) { user.send_reset_password_instructions }

    context 'with valid token and passwords' do
      it 'resets the password and returns a success message' do
        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }
        }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Password has been reset successfully.')
        expect(user.reload).to be_valid_password('newpassword')
      end
    end

    context 'with invalid token or passwords' do
      it 'returns an error message for invalid token' do
        put :update, params: {
          user: {
            reset_password_token: 'invalid_token',
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }
        }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include('Reset password token is invalid')
      end

      it 'returns an error if password confirmation does not match' do
        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'newpassword',
            password_confirmation: 'mismatch'
          }
        }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
