Starterapp::Application.routes.draw do

  get "bubble_cloud/view1"
  get "bubble_cloud/view2"
  get "bubble_cloud/view3"
  get "bubble_cloud/view4"
  resources :users
  root 'pages#home'
  get 'tweets/:type' => 'pages#home'
  get 'tweets/user/:other' => 'pages#other'
  get 'auth/:provider' => 'sessions#new', :as => :signin
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout
end
