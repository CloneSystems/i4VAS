Greenbone::Application.routes.draw do

  resources :scan_targets

  resources :scan_configs

  resources :tasks

  resources :openvas_cli_vas_tasks
  root :to => 'openvas_cli_vas_tasks#index'
  
  get 'home' => 'home#index'

end