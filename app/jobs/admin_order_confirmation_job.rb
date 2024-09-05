# frozen_string_literal: true

class AdminOrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return nil unless order&.paid

    NotificationsService::Order::AdminOrderConfirmation.send(order:)
  end
end
