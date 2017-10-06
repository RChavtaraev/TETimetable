Rails.application.routes.draw do



  root 'timetables#home'
  resources :customers
  resources :places


  get "appointments/new_dialog" => 'appointments#new_dialog', :as => :new_dialog
  get "appointments/:id/edit_dialog" => 'appointments#edit_dialog', :as => :edit_dialog
  get 'timetables/home'
  get 'timetables/editweek', to: 'timetables#editweek'
  post 'timetables/check_uncheck', to: 'timetables#check_uncheck'

  resources :appointments do
    get :autocomplete_customer_name, :on => :collection
    #get :edit_dialog, :to => 'edit_dialog', :as => :edit_dialog
  end

  resources :timetables do
    #get 'editweek', to: 'timetables#editweek'
    #post 'check_uncheck', to: :check_uncheck
  end

  resources :users
  match '/signup',  to: 'users#new', via: 'get'


  resources :sessions, only: [:new, :create, :destroy]
  match  '/signin',  to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
