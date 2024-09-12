# frozen_string_literal: true

Rails.application.routes.draw do
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
  devise_scope :user do
    get 'users/check_admin', to: 'users/sessions#check_admin'
  end

  resources :products, only: %i[index show create edit update] do
    member do
      get 'price_by_id'
      get 'similar_products'
    end
    collection do
      post 'cart_total'
      post 'validate_cart'
      post 'validate_product'
      get 'admin_index'
      get 'front_page_products'
    end
  end

  resources :orders, only: %i[index create update] do
    collection do
      get :admin_index
      get :success
    end
    member do
      get :track_order
    end
  end

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
