# frozen_string_literal: true

class Product < ApplicationRecord
  before_create :generate_custom_id

  has_many :order_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
  validates :product_type, presence: true, inclusion: { in: %w[men women unisex] }
  validates :cover_image, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }, allow_blank: true
  validates :sub_images, presence: true, if: :images?

  validate :sub_images_urls_format
  validate :valid_sizes

  def sub_images_urls_format
    sub_images.each do |url|
      errors.add(:sub_images, 'must contain valid URLs') unless url&.match?(URI::DEFAULT_PARSER.make_regexp(%w[http https]))
    end
  end

  def valid_sizes
    allowed_sizes = %w[XXS XS S M L XL XXL XXXL]
    sizes.each do |size|
      errors.add(:sizes, "#{size} is not a valid size") unless allowed_sizes.include?(size)
    end
  end

  def images?
    sub_images.present?
  end

  def generate_custom_id
    date_component = Time.current.strftime('%y%m%d')
    random_component = SecureRandom.random_number(10_000).to_s.rjust(5, '0')
    self.id = "#{date_component}#{random_component}"
  end
end
