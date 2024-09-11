# frozen_string_literal: true

module ProductsService
  class UserFilterProducts
    VALID_SORT_COLUMNS = %w[created_at price].freeze
    VALID_SORT_DIRECTIONS = %w[asc desc].freeze

    def self.call(params)
      products = Product.where(active: true)

      products = products.where('name ILIKE ?', "%#{params[:name]}%") if params[:name].present?

      sort_by = params[:sort_by].presence_in(VALID_SORT_COLUMNS) || 'created_at'
      sort_direction = params[:sort_direction].presence_in(VALID_SORT_DIRECTIONS) || 'asc'

      products.order("#{sort_by} #{sort_direction}")
    end
  end
end
