ActiveAdmin.register ACrmUser do

  menu parent: "CRM Data"

  config.batch_actions = false
  actions :index, :show

  scope :all
  scope :active
  scope :active_managers, default: true
  
end
