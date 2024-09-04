# frozen_string_literal: true

class OrderShippedJob < ApplicationJob
  queue_as :default

  def perform(to, order_id)
    order = Order.find(order_id)
    NotificationsService::Order::OrderShipped.send(to:, order:)
  end
end
