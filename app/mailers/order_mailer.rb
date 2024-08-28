# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME']

  def confirmation_email(order)
    @order = order
    @order_items = order.order_items

    @total_price = @order_items.sum { |item| item.product.price * item.quantity }
    @delivery_address = @order.delivery.address

    mail(to: @order.email, subject: "Order Confirmation ##{@order.id}")
  end
end
