Starterapp::Application.routes.draw do

  resources :users
  root 'pages#home'
  get 'tweets/:type' => 'pages#home'
  get 'auth/:provider' => 'sessions#new', :as => :signin
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout
end
