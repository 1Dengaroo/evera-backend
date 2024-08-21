# frozen_string_literal: true

Rails.application.routes.draw do
  get "orders/create"
  namespace :api do
    namespace :v1 do
      resources :products
      resources :orders, only: [:create]
    end
  end
end
