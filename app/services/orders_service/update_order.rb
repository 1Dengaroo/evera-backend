# frozen_string_literal: true

module OrdersService
  class UpdateOrder
    def self.call(order_id:, order_params:)
      order = Order.find_by(id: order_id)
      return nil unless order

      delivery_params = order.delivery.attributes.symbolize_keys.merge(order_params[:delivery_attributes] || {})

      raise ActiveRecord::RecordInvalid, order unless order.update!(order_params.merge(delivery_attributes: delivery_params))

      order
    end
  end
end
