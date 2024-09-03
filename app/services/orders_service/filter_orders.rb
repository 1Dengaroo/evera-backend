# frozen_string_literal: true

module OrdersService
  class FilterOrders
    def self.call(params)
      orders = Order.where(paid: true).order(created_at: :desc)

      orders = orders.where(email: params[:email]) if params[:email].present?
      orders = orders.joins(:delivery).where(deliveries: { status: params[:status] }) if params[:status].present?
      orders = orders.where(id: params[:id]) if params[:id].present?

      orders
    end
  end
end
