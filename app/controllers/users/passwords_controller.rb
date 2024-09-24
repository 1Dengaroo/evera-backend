# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  def update_password
    user = current_user

    if user.nil?
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
      return
    end

    if user.valid_password?(params[:current_password])
      if user.update!(password_params)
        render json: { message: 'Password has been reset successfully.' }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Current password is incorrect' }, status: :unauthorized
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user.present?
      user.send_reset_password_instructions
      render json: { message: 'You will receive an email with instructions on how to reset your password in a few minutes.' }, status: :ok
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end

  def update
    user = User.reset_password_by_token(reset_password_params)

    if user.errors.empty?
      render json: { message: 'Password has been reset successfully.' }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def reset_password_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end
end
