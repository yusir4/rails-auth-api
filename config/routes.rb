Rails.application.routes.draw do
  resources :users
  post "/login", to: "users#login"
  post "/logout", to: "users#logout"
  get "/follow/:id", to: "users#follow"
end
