Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, path: '/v1' do
      resources :text_messages, only: [:index, :create]
      post 'delivery_status', to: 'text_messages#delivery_status'
    end
  end
end
