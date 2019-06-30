Rails.application.routes.draw do
  get 'home/index'

  resources :users, only: %i[new create edit update] do
    resources :messages, only: %i[index]
  end

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  root to: "home#index"

  get 'users/:id', to: 'users#show', constraints: { id: /[0-9a-zA-Z\.\-\_]+/ }

  resources :password_resets, only: %i[new create show update]
end
