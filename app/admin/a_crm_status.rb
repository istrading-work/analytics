ActiveAdmin.register ACrmStatus do

  menu parent: "CRM Data"

  config.batch_actions = false
  actions :index, :show

  index do
    selectable_column
    column :code
    column :name
    column :crm_group, :sortable=>:"a_crm_status_groups.name"
    column :is_active
    column :created_at
    column :updated_at
  end
  
  scope :joined, :default => true do |a_crm_statuses|
    a_crm_statuses.includes [:crm_group]
  end
 
end
