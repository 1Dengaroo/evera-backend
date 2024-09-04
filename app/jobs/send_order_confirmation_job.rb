# frozen_string_literal: true

class SendOrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(to, order_id)
    order = Order.find_by(id: order_id)
    return nil unless order

    NotificationsService::Order::OrderConfirmation.send(to:, order:)
  end
end
