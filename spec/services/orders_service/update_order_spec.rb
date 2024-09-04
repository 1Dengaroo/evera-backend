# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersService::UpdateOrder, type: :service do
  let!(:order) { create(:order) }
  let!(:delivery) { create(:delivery, order:, status: 'manufacturing') }

  before do
    allow(OrderShippedJob).to receive(:perform_later)
    allow(OrderDeliveredJob).to receive(:perform_later)
  end

  describe '.call' do
    context 'when the order exists' do
      it 'updates the order and delivery successfully' do
        delivery_params = { status: 'shipped', tracking_information: '12345' }
        order_params = { delivery_attributes: delivery_params }

        updated_order = described_class.call(order_id: order.id, order_params:)

        expect(updated_order).to be_persisted
        expect(updated_order.delivery.status).to eq('shipped')
        expect(updated_order.delivery.tracking_information).to eq('12345')
        expect(OrderShippedJob).to have_received(:perform_later).with(order.email, order.id)
        expect(OrderDeliveredJob).not_to have_received(:perform_later)
      end

      it 'raises an error if the update fails due to invalid params' do
        order_params = { delivery_attributes: { status: nil } }

        expect do
          described_class.call(order_id: order.id, order_params:)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the order does not exist' do
      it 'returns nil' do
        result = described_class.call(order_id: 0, order_params: {})
        expect(result).to be_nil
      end
    end

    context 'when the order status is changing from shipped to delivered' do
      it 'queues the OrderDeliveredJob' do
        delivery_params = { status: 'delivered' }
        order_params = { delivery_attributes: delivery_params }
        delivery.update!(status: 'shipped')

        described_class.call(order_id: order.id, order_params:)

        expect(OrderDeliveredJob).to have_received(:perform_later).with(order.email, order.id)
        expect(OrderShippedJob).not_to have_received(:perform_later)
      end
    end
  end
end
