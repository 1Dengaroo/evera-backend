# frozen_string_literal: true

class SendOrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)

    return unless order&.paid?

    OrderMailer.confirmation_email(order).deliver_later
  end
end
