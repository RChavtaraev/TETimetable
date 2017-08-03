Rails.application.routes.draw do
  root 'timetable#home'
  resources :customers
  resources :appointments do
    get :autocomplete_customer_name, :on => :collection
  end
  get 'timetable/home'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
