Rails.application.routes.draw do



  root 'timetables#home'
  resources :customers

  resources :appointments do
    get :autocomplete_customer_name, :on => :collection
  end

  get 'timetables/home'
  get 'timetables/editweek', to: 'timetables#editweek'
  post 'timetables/check_uncheck', to: 'timetables#check_uncheck'

  resources :timetables do
    #get 'editweek', to: 'timetables#editweek'
    #post 'check_uncheck', to: :check_uncheck
  end

  resources :users
  match '/signup',  to: 'users#new', via: 'get'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
