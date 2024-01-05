Rails.application.routes.draw do
  root "static_pages#top"
  resources :vues, only: %i[index]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
