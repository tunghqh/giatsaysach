Rails.application.routes.draw do
  devise_for :users, path_names: {
    sign_in: 'login',
    sign_out: 'logout'
  }

  get 'home/index'

  # Laundry management routes
  resources :customers, only: [:index, :show, :edit, :update]

  # Trang giới thiệu cho khách hàng
  get 'intro', to: 'customers#intro', as: :customer_intro
  resources :orders do
    member do
      patch :start_washing
      patch :complete_washing
      patch :make_payment
      get :print_invoice
    end
  end

  # Shift management for staff
  resources :shifts, only: [:index, :create, :edit, :update]

  # AJAX routes
  get 'search_customer', to: 'orders#search_customer'
  get 'phone_search', to: 'orders#phone_search'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Admin statistics
    get 'statistics', to: 'statistics#index', as: :statistics

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "orders#index"
end
