Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Lightweight health check for Kamal-proxy / uptime monitors.
  # Rails 7.0 has no built-in "/up" (added in 7.1), so provide a simple 200.
  get "up", to: ->(_env) { [ 200, { "Content-Type" => "text/plain" }, [ "OK" ] ] }

  # Catalog (login required — enforced in the controllers).
  resources :products, only: [:index, :show]
  resources :brands, only: [:index, :show]

  # Defines the root path route ("/")
  root "home#index"
end
