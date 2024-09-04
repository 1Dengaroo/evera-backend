# frozen_string_literal: true

class OrderDeliveredJob < ApplicationJob
  queue_as :default

  def perform(to, order_id)
    order = Order.find_by(id: order_id)
    NotificationsService::Order::OrderDelivered.send(to:, order:)
  end
end
