# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, path: '', path_names: {
                                 sign_in: 'login',
                                 sign_out: 'logout',
                                 registration: 'signup'
                               },
                     controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations',
                       passwords: 'users/passwords'
                     }

  # Product routes
  resources :products, only: %i[index show] do
    member do
      get 'price_by_id'
    end
    collection do
      post 'cart_total'
      get 'front_page_products'
    end
  end

  # Order routes
  resources :orders, only: %i[index create update] do
    collection do
      get :admin_index
      get :success
    end
    member do
      get :track_order
    end
  end

  # Configuration routes
  resources :configurations do
    collection do
      get 'stripe_public_key'
    end
  end

  # Webhook routes
  resources :webhooks, only: [] do
    collection do
      post 'stripe'
    end
  end
end
