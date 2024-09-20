Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "billing_months#index"
  resources :repos
  resources :repo_costs, only: [:show]
  resources :billing_months, param: :month
  resources :billing_months do 
    resources :repo_costs, only: [:index]
  end
  resources :business_units
end
