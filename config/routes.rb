# frozen_string_literal: true

Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  # Route signup to users_controller.new
  get '/signup', to: 'users#new'
  # Session controller routes
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  # Uses the special 'resources' method to auto obtain a full suite of RESTful routes
  resources :users do
    # Add a member block to give us routes that respond to URLs containing the user ID
    # i.e. GET /users/1/following and GET /users/1/followers
    # also gives us following_user_url and following_user_path
    member do
      get :following, :followers
    end
  end
  # Using the resources method to create a RESTful 'edit' route for account activations
  resources :account_activations, only: [:edit]
  resources :password_resets, only: %i[new create edit update]
  resources :microposts, only: %i[create destroy]
  resources :relationships, only: %i[create destroy]
  # To cope with submission errors or copy/paste of the /microposts URL
  # this will redirect
  get '/microposts', to: 'static_pages#home'
end
