# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:valid_url) { 'https://example.com/image.jpg' }
  let(:invalid_url) { 'invalid_url' }

  describe 'validations' do
    it 'is valid with valid attributes' do
      product = FactoryBot.build(:product)
      expect(product).to be_valid
    end

    it 'is invalid without a name' do
      product = FactoryBot.build(:product, name: nil)
      expect(product).not_to(be_valid)
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a negative price' do
      product = FactoryBot.build(:product, price: -10)
      expect(product).not_to(be_valid)
      expect(product.errors[:price]).to include('must be greater than or equal to 0')
    end

    it 'is invalid without a product type' do
      product = FactoryBot.build(:product, product_type: nil)
      expect(product).not_to(be_valid)
      expect(product.errors[:product_type]).to include("can't be blank")
    end

    it 'is invalid with an invalid product type' do
      product = FactoryBot.build(:product, product_type: 'kids')
      expect(product).not_to(be_valid)
      expect(product.errors[:product_type]).to include('is not included in the list')
    end

    it 'is invalid with an invalid cover image URL' do
      product = FactoryBot.build(:product, cover_image: invalid_url)
      expect(product).not_to(be_valid)
      expect(product.errors[:cover_image]).to include('must be a valid URL')
    end

    it 'is valid with a blank cover image URL' do
      product = FactoryBot.build(:product, cover_image: nil)
      expect(product).to be_valid
    end

    it 'is invalid with invalid sub image URLs' do
      product = FactoryBot.build(:product, sub_images: [valid_url, invalid_url])
      expect(product).not_to(be_valid)
      expect(product.errors[:sub_images]).to include('must contain valid URLs')
    end

    it 'is invalid with an invalid size' do
      product = FactoryBot.build(:product, sizes: ['InvalidSize'])
      expect(product).not_to(be_valid)
      expect(product.errors[:sizes]).to include('InvalidSize is not a valid size')
    end

    it 'is valid with all correct sizes' do
      product = FactoryBot.build(:product, sizes: %w[XS S M L XL XXL])
      expect(product).to be_valid
    end

    it 'is valid when sub_images is empty and cover_image is present' do
      product = FactoryBot.build(:product, cover_image: valid_url, sub_images: [])
      expect(product).to be_valid
    end
  end

  describe '#sub_images_urls_format' do
    it 'is invalid if any sub image URL is invalid' do
      product = FactoryBot.build(:product, sub_images: [valid_url, invalid_url])
      expect(product).not_to(be_valid)
      expect(product.errors[:sub_images]).to include('must contain valid URLs')
    end
  end

  describe '#valid_sizes' do
    it 'is invalid if any size is not in the allowed list' do
      product = FactoryBot.build(:product, sizes: %w[XS InvalidSize])
      expect(product).not_to(be_valid)
      expect(product.errors[:sizes]).to include('InvalidSize is not a valid size')
    end
  end

  describe 'associations' do
    it 'has many order_items' do
      order = create(:order)
      product = create(:product)
      order_item1 = create(:order_item, order:, product:)
      order_item2 = create(:order_item, order:, product:)

      expect(product.order_items).to include(order_item1, order_item2)
    end
  end
end
