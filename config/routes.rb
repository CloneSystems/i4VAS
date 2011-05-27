Greenbone::Application.routes.draw do

  devise_for :users

  resources :tasks
  get 'start_task/:id'          => 'tasks#start_task',          :as => 'start_task'
  get 'pause_task/:id'          => 'tasks#pause_task',          :as => 'pause_task'
  get 'resume_paused_task/:id'  => 'tasks#resume_paused_task',  :as => 'resume_paused_task'
  get 'stop_task/:id'           => 'tasks#stop_task',           :as => 'stop_task'
  get 'resume_stopped_task/:id' => 'tasks#resume_stopped_task', :as => 'resume_stopped_task'
  root :to => 'tasks#index'

  resources :reports
  get 'view_report/:id' => 'reports#view_report', :as => 'view_report'

  resources :scan_targets

  resources :scan_configs

  resources :openvas_cli_vas_tasks

  get 'home' => 'home#index'

end