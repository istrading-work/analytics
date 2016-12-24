Rails.application.routes.draw do

  #get 'sync/betapro'
  get 'sync/export_to_betapro'

  #get 'a_crm_orders/russian_post'
  #get 'a_crm_orders/russian_post/:id', to: 'a_crm_orders#russian_post', as: 'russian_post'
  get 'orders/:num', to: 'a_crm_orders#russian_post', as: 'russian_post'
  devise_for :a_admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
