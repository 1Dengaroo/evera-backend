# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { 'Sample Product' }
    price { 19.99 }
    active { true }
    product_type { 'unisex' }
    cover_image { 'https://example.com/cover_image.jpg' }
    sub_images { ['https://example.com/sub_image1.jpg', 'https://example.com/sub_image2.jpg'] }
    sizes { %w[XS S M L XL XXL] }
    quantity { 10 }
  end
end
