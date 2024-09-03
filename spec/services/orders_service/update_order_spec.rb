# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersService::UpdateOrder, type: :service do
  let!(:order) { create(:order) }
  let!(:delivery) { create(:delivery, order:, status: 'processing') }

  describe '.call' do
    context 'when the order exists' do
      it 'updates the order and delivery successfully' do
        delivery_params = { status: 'shipped', tracking_information: '12345' }
        order_params = { delivery_attributes: delivery_params }

        updated_order = described_class.call(order_id: order.id, order_params:)

        expect(updated_order).to be_persisted
        expect(updated_order.delivery.status).to eq('shipped')
        expect(updated_order.delivery.tracking_information).to eq('12345')
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
  end
end
