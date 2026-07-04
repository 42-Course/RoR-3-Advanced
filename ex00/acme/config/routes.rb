Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Lightweight health check for Kamal-proxy / uptime monitors.
  # Rails 7.0 has no built-in "/up" (added in 7.1), so provide a simple 200.
  get "up", to: ->(_env) { [ 200, { "Content-Type" => "text/plain" }, [ "OK" ] ] }

  # Defines the root path route ("/")
  # root "articles#index"
end
