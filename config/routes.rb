Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    post "/api/v1/auth/signup", to: "api/v1/registrations#create"
  end

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, path: '/v1' do
      resources :text_messages, only: [:index, :create]
      post 'delivery_status', to: 'text_messages#delivery_status'
    end
  end
end
