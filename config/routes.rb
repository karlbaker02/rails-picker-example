Rails.application.routes.draw do
  resources :answers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'answers#new'
end
