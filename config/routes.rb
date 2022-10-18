Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Devise routes for API clients (custom sessions controller)
      devise_scope :user do
        post 'users/sign_in', to: 'users/sessions#create'
        delete 'users/sign_out', to: 'users/sessions#destroy'
        post 'users', to: 'users/registrations#create'
      end
    end
  end
end
