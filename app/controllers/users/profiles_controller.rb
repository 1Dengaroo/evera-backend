# frozen_string_literal: true

class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    user = current_user
    if user.nil?
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
      return
    end

    render json: { email: user.email, name: user.name, phone_number: user.phone_number&.number }, status: :ok
  end

  def update
    user = current_user

    if user.nil?
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
      return
    end

    if user.update(user_params)
      render json: { message: 'Profile updated successfully.' }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:name, :email, phone_number_attributes: [:number])
  end
end
