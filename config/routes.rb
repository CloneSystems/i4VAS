Greenbone::Application.routes.draw do

  devise_for :users

  resources :openvas_users

  resources :tasks
  get 'start_task/:id'          => 'tasks#start_task',          :as => 'start_task'
  get 'pause_task/:id'          => 'tasks#pause_task',          :as => 'pause_task'
  get 'resume_paused_task/:id'  => 'tasks#resume_paused_task',  :as => 'resume_paused_task'
  get 'stop_task/:id'           => 'tasks#stop_task',           :as => 'stop_task'
  get 'resume_stopped_task/:id' => 'tasks#resume_stopped_task', :as => 'resume_stopped_task'
  get 'tbd' => 'tasks#tbd', :as => 'tbd'
  root :to => 'tasks#index'

  resources :reports
  get 'view_report/:id' => 'reports#view_report', :as => 'view_report'

  resources :report_formats

  resources :scan_targets

  resources :scan_configs
  get 'export_config/:id' => 'scan_configs#export_config', :as => 'export_config'

  resources :schedules

  get 'settings' => 'admin_settings#index', :as => 'settings'

  get 'feeds' => 'nvt_feeds#index', :as => 'feeds'
  get 'sync_feed' => 'nvt_feeds#sync_feed', :as => 'sync_feed'

  resources :system_reports

  resources :families

  resources :preferences

  resources :escalators
  get 'test_escalator/:id' => 'escalators#test_escalator', :as => 'test_escalator'

  resources :slaves

  resources :credentials
  get 'download_public_key/:id' => 'credentials#download_public_key', :as => 'download_public_key'
  get 'download_format/:id' => 'credentials#download_format', :as => 'download_format'

  resources :notes

  resources :overrides

end