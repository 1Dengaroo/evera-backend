# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  def check_admin
    token = request.headers['Authorization']&.split(' ')&.last
    if token.blank?
      return render json: { status: 401, message: 'No token provided' }, status: :unauthorized
    elsif token.split('.').size != 3
      return render json: { status: 401, message: 'Malformed token' }, status: :unauthorized
    end

    begin
      jwt_payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256' }).first
      current_user = User.find(jwt_payload['sub'])
    rescue JWT::DecodeError
      return render json: { status: 401, message: 'Invalid token' }, status: :unauthorized
    end

    if current_user.admin?
      render json: { status: 200, message: 'User is admin', is_admin: true }, status: :ok
    else
      render json: { status: 403, message: 'User is not admin', is_admin: false }, status: :forbidden
    end
  end

  private

  def respond_with(current_user, _opts = {})
    request.env['warden-jwt_auth.token']
    render json: {
      status: {
        code: 200, message: 'Logged in successfully',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    return render json: { status: 401, message: 'No token provided' }, status: :unauthorized if request.headers['Authorization'].blank?

    token = request.headers['Authorization'].split(' ').last
    return render json: { status: 401, message: 'Malformed token' }, status: :unauthorized unless token.present? && token.split('.').size == 3

    begin
      jwt_payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256' }).first
      current_user = User.find(jwt_payload['sub'])
    rescue JWT::DecodeError
      return render json: { status: 401, message: 'Invalid token' }, status: :unauthorized
    end

    if current_user
      render json: { status: 200, message: 'Logged out successfully' }, status: :ok
    else
      render json: { status: 401, message: 'Session expired' }, status: :unauthorized
    end
  end
end
