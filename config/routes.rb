Rails.application.routes.draw do

  devise_for :users
  root 'home#index'

  resources :users, only: [:show]
  resources :orders, only: [:new]
  resources :items, only: [:show, :new, :create]

end
  