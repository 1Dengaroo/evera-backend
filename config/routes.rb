# frozen_string_literal: true

Rails.application.routes.draw do
  get 'orders/create'
  resources :products, only: %i[index show] do
    member do
      get 'price_by_id'
    end
    collection do
      post 'cart_total'
    end
  end

  resources :orders, only: [:create]

  resources :configurations do
    collection do
      get 'stripe_public_key'
    end
  end

  resources :webhooks, only: [] do
    collection do
      post 'stripe'
    end
  end
end
