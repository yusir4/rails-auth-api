Rails.application.routes.draw do
  resource :users
  post "/login", to: "users#login"
  post "/logout", to: "users#logout"
end
