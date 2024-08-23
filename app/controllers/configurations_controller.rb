# frozen_string_literal: true

class ConfigurationsController < ApplicationController
  def stripe_public_key
    render json: { stripe_public_key: ENV['STRIPE_PUBLIC_KEY'] }
  end
end
