Rails.application.routes.draw do

  get 'pencairan/log', to: 'pencairans#get_by_id'
  post 'pencairan/log', to: 'pencairans#get_by_id'
  put 'pencairan', to: 'pencairans#update'
  get 'pencairan', to: 'pencairans#index'
  post 'pencairan/add', to: 'pencairans#create'  
  get 'pencairan/get_approval_depthead', to: 'pencairans#get_approval_depthead'
  post 'pencairan/get_approval_depthead', to: 'pencairans#get_approval_depthead'
  resources :pencairans
  
  put 'debitur', to: 'debiturs#update'
  post 'debitur/add', to: 'debiturs#create'
  resources :debiturs
  # Akses Modul
  get 'aksesmodul/list', to: 'aksesmoduls#show'
  get 'aksesmodul/get_modul_by_role', to: 'aksesmoduls#get_modul_by_role'
  get 'aksesmodul', to: 'aksesmoduls#index'
  post 'aksesmodul/update', to: 'aksesmoduls#update'
  post 'aksesmodul', to: 'aksesmoduls#create'
  resources :aksesmoduls
  # user_role
  get 'user_role/list', to: 'user_roles#show'
  get 'user_role', to: 'user_roles#index'
  get 'user_role/get_role_all', to: 'user_roles#get_role_all'
  put 'user_role', to: 'user_roles#update'
  post 'user_role', to: 'user_roles#create'
  get 'user_role/get_all', to: 'user_roles#get_all'
  resources :user_roles
  # modul
  get 'modul/list', to: 'moduls#show'
  get 'modul', to: 'moduls#index'
  get 'modul/get_all', to: 'moduls#get_all'
  post 'modul', to: 'moduls#create'
  put 'modul', to: 'moduls#update'
  resources :moduls
  #users
    post 'user', to: 'users#create'
    put 'user', to: 'users#update'
    get 'user', to: 'users#index'
    get 'user/list', to: 'users#show'
    get 'user/login', to: 'users#login'
    get 'user/get_all', to: 'users#get_all'
  resources :users
  namespace :v10 do
    post 'mandiri/request_batch'
    get 'mandiri/get_request_batch'
    post 'mandiri/view_batch_list'
    get 'mandiri/view_batch'
    get 'mandiri/view_batch_detail'
    get 'mandiri/projection_batch'
    post 'mandiri/approval_batch'
    post 'mandiri/check_batch'
    post 'mandiri/update_batch'
    post 'mandiri/request_ospk'
    post 'mandiri/create_npl'
    get 'mandiri/view_npl'
    post 'mandiri/update_npl'
    get 'mandiri/view_batch_total'
    get 'mandiri/view_detail_npl'
    post 'mandiri/list_approval_batch'
  end
  resources :system_settings
  resources :sessions
  post 'apps/request_token', to: 'apps#request_token'
  resources :apps
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
