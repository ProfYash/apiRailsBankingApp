Rails.application.routes.draw do
  post "/users/login", to: "users#login"
  resources :users do
    resources :accounts do
      post "transfer", to: "accounts#transfer"
      post "deposit", to: "accounts#deposit"
      post "withdraw", to: "accounts#withdraw"
    end
  end
  resources :banks
end
