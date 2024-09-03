# frozen_string_literal: true

# app/services/products_service/filter_products.rb
module ProductsService
  class FilterProducts
    def self.call(params)
      products = Product.all

      products = products.where(active: params[:active]) if params[:active].present?
      products = products.where('name ILIKE ?', "%#{params[:name]}%") if params[:name].present?

      if params[:created_at].present?
        start_date = parse_date(params[:created_at][:start_date])
        end_date = parse_date(params[:created_at][:end_date])&.end_of_day

        return Product.none if start_date.nil? || end_date.nil?

        products = products.where(created_at: start_date..end_date)
      end

      if params[:sort_by_date].present?
        direction = params[:sort_by_date] == 'desc' ? :desc : :asc
        products = products.order(created_at: direction)
      end

      products
    end

    def self.parse_date(date_string)
      Date.parse(date_string)
    rescue StandardError
      nil
    end
  end
end
