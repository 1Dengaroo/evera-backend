# frozen_string_literal: true

module OrdersService
  class UpdateOrder
    def self.call(order_id:, order_params:)
      order = Order.find_by(id: order_id)
      return nil unless order

      old_status = order.delivery.status

      delivery_params = order.delivery.attributes.symbolize_keys.merge(order_params[:delivery_attributes] || {})
      merged_params = order_params.merge(delivery_attributes: delivery_params).to_h

      new_status = merged_params.dig(:delivery_attributes, :status)

      raise ActiveRecord::RecordInvalid, order unless order.update!(merged_params)

      OrderShippedJob.perform_later(order.email, order.id) if new_status == 'shipped' && old_status == 'manufacturing'
      OrderDeliveredJob.perform_later(order.email, order.id) if new_status == 'delivered' && old_status == 'shipped'

      order
    end
  end
end
