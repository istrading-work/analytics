ActiveAdmin.register AUserShop do
  permit_params :a_admin_user_id, :a_crm_shop_id 

  menu parent: "Analytics Data" 
  config.batch_actions = false

  index do
    id_column
    column :a_admin_user
    column :a_crm_shop
    actions
  end
  
  form do |f|
    f.inputs "Admin Details" do
      f.input :a_admin_user_id
      f.input :a_crm_shop
    end
    f.actions
  end
  
end
