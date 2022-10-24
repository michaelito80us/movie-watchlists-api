Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'index', to: 'movies#index'
      get 'movies/:tmdb_movie_id', to: 'movies#show'
      get 'search', to: 'movies#search'
      resources :watchlists
      get 'history', to: 'histories#index'
    end
  end
end
