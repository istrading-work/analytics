ActiveAdmin.register ACrmUser do

  config.remove_action_item(:new)
  
  index do
    selectable_column
    column :id
	column :first_name
	column :last_name
    column :email
    column :is_manager
    column :is_active
  end
  
  filter :id
  filter :first_name
  filter :last_name
  filter :email
  filter :is_manager
  filter :is_active
  
end