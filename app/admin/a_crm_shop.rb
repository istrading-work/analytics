ActiveAdmin.register ACrmShop do

  config.remove_action_item(:new)
  config.batch_actions = false

  index do
    selectable_column
    column :code
    column :name
    column :is_active
    column :created_at
    column :updated_at
  end
 
end
