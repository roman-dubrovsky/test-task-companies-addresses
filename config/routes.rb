Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :companies, only: [:create] do
    post :import, on: :collection
  end
end
