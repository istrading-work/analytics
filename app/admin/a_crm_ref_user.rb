ActiveAdmin.register ACrmRefUser do

  config.remove_action_item(:new)
  
  index do
    selectable_column
    id_column
	column :first_name
	column :last_name
    column :email
    column :is_manager
    column :is_active
    column :crm_user_id
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :is_manager
  filter :is_active
  filter :crm_user_id
  
end