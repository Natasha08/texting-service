Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, path: '/v1' do
      resources :messages, only: [:index]
    end
  end
end
