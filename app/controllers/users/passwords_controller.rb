# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

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
