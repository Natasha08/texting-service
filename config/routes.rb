Rails.application.routes.draw do
  mount ActionCable.server, at: '/cable'

  devise_for :users

  devise_scope :user do
    post "/api/v1/auth/signup", to: "api/v1/registrations#create"
  end

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, path: '/v1' do
      post 'auth/login', to: 'login#create'
      resources :text_messages, only: [:index, :create]
      post 'delivery_status', to: 'text_messages#delivery_status'
    end
  end

  root to: 'api/v1/home#show'
end
