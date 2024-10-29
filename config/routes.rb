Rails.application.routes.draw do
  namespace :admin do
      resources :users
      resources :meetings  #, except: [:destroy]
      resources :bookings #, only: [:index, :show]

      root to: "users#index"
    end
  devise_for :users
  root 'pages#home'


  get 'about', to: "pages#about"
  get 'contact', to: "pages#contact"
  get 'dashboard', to: "pages#dashboard"
  get 'thank_you', to: "pages#thank_you"
  get 'receipt/:booking_id', to: "pages#receipt", as: "receipt_pdf"
  get 'zoom/:meeting_id', to: "pages#zoom", as: "zoom_view"
  
  post 'purchase', to: 'pays#purchase'
  post 'join', to: 'pays#join_free'

  
end
