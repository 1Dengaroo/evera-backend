# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksService::Stripe, type: :service do
  describe '.cs_completed' do
    let(:event) do
      {
        'data' => {
          'object' => {
            'id' => 'cs_test_123',
            'customer_details' => {
              'email' => 'customer@example.com'
            },
            'shipping_details' => {
              'address' => {
                'city' => 'New York',
                'country' => 'US',
                'line1' => '123 Main St',
                'line2' => 'Apt 4',
                'postal_code' => '10001',
                'state' => 'NY'
              },
              'name' => 'John Doe'
            },
            'total_details' => {
              'amount_shipping' => 500,
              'amount_tax' => 100
            },
            'shipping_cost' => {
              'shipping_rate' => 'shr_123'
            }
          }
        }
      }
    end

    let(:session) { event['data']['object'] }
    let(:order) { instance_double(Order, id: 1, order_items:, checkout_session_id: session['id']) }
    let(:order_items) { [order_item] }
    let(:order_item) { instance_double(OrderItem, product:, quantity: 2) }
    let(:product) { instance_double(Product, quantity: 10) }
    let(:address) { instance_double(Address) }

    before do
      allow(Order).to receive(:find_by).with(checkout_session_id: session['id']).and_return(order)
      allow(order).to receive(:update!).with(paid: true, email: session['customer_details']['email'])
      allow(product).to receive(:update!).with(quantity: product.quantity - order_item.quantity)
      allow(order).to receive(:update!).with(amount_shipping: session['total_details']['amount_shipping'],
                                             amount_tax: session['total_details']['amount_tax'],
                                             shipping_code: session['shipping_cost']['shipping_rate'])
      allow(Address).to receive(:create!).with(
        city: session['shipping_details']['address']['city'],
        country: session['shipping_details']['address']['country'],
        line1: session['shipping_details']['address']['line1'],
        line2: session['shipping_details']['address']['line2'],
        postal_code: session['shipping_details']['address']['postal_code'],
        state: session['shipping_details']['address']['state'],
        name: session['shipping_details']['name']
      ).and_return(address)
      allow(order).to receive(:create_delivery!).with(
        email: session['customer_details']['email'],
        address:,
        session_id: session['id']
      )
      allow(SendOrderConfirmationJob).to receive(:perform_later).with(session['customer_details']['email'], order.id)
      allow(AdminOrderConfirmationJob).to receive(:perform_later).with(order.id)
    end

    context 'when order is found' do
      it 'updates the order as paid' do
        described_class.cs_completed(event)
        expect(order).to have_received(:update!).with(paid: true, email: session['customer_details']['email'])
      end

      it 'updates the product quantity' do
        described_class.cs_completed(event)
        expect(product).to have_received(:update!).with(quantity: product.quantity - order_item.quantity)
      end

      it 'updates the order with shipping and tax details' do
        described_class.cs_completed(event)
        expect(order).to have_received(:update!).with(
          amount_shipping: session['total_details']['amount_shipping'],
          amount_tax: session['total_details']['amount_tax'],
          shipping_code: session['shipping_cost']['shipping_rate']
        )
      end

      it 'creates the address' do
        described_class.cs_completed(event)
        expect(Address).to have_received(:create!).with(
          city: session['shipping_details']['address']['city'],
          country: session['shipping_details']['address']['country'],
          line1: session['shipping_details']['address']['line1'],
          line2: session['shipping_details']['address']['line2'],
          postal_code: session['shipping_details']['address']['postal_code'],
          state: session['shipping_details']['address']['state'],
          name: session['shipping_details']['name']
        )
      end

      it 'creates the delivery for the order' do
        described_class.cs_completed(event)
        expect(order).to have_received(:create_delivery!).with(
          email: session['customer_details']['email'],
          address:,
          session_id: session['id']
        )
      end

      it 'sends the order confirmation email' do
        described_class.cs_completed(event)
        expect(SendOrderConfirmationJob).to have_received(:perform_later).with(session['customer_details']['email'], order.id)
      end

      it 'sends the admin order confirmation email' do
        described_class.cs_completed(event)
        expect(AdminOrderConfirmationJob).to have_received(:perform_later).with(order.id)
      end
    end

    context 'when order is not found' do
      before do
        allow(Order).to receive(:find_by).with(checkout_session_id: session['id']).and_return(nil)
      end

      it 'does not update the order' do
        described_class.cs_completed(event)
        expect(order).not_to have_received(:update!)
      end

      it 'does not update the product quantity' do
        described_class.cs_completed(event)
        expect(product).not_to have_received(:update!)
      end

      it 'does not create the address' do
        described_class.cs_completed(event)
        expect(Address).not_to have_received(:create!)
      end

      it 'does not create the delivery for the order' do
        described_class.cs_completed(event)
        expect(order).not_to have_received(:create_delivery!)
      end

      it 'does not send the order confirmation email' do
        described_class.cs_completed(event)
        expect(SendOrderConfirmationJob).not_to have_received(:perform_later)
      end

      it 'does not send the admin order confirmation email' do
        described_class.cs_completed(event)
        expect(AdminOrderConfirmationJob).not_to have_received(:perform_later)
      end
    end
  end
end
