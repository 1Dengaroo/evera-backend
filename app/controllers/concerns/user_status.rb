# frozen_string_literal: true

module UserStatus
  extend ActiveSupport::Concern

  def authenticate_user_status!
    render json: { error: 'Unauthorized access' }, status: :unauthorized unless current_user
  end

  def authenticate_admin_status!
    render json: { error: 'Unauthorized access' }, status: :forbidden unless current_user&.admin?
  end
end
