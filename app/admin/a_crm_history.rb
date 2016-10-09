ActiveAdmin.register ACrmHistory do

  menu parent: "CRM Data"

  config.batch_actions = false
  actions :index, :show

  index do |el|
    column :id
    column :dt
    column :a_crm_order_id
    column :a_crm_status
    column :last_updated_at
    actions
  end

  filter :a_crm_order_id
  filter :a_crm_status, :as => :select
  
  controller do
    def scoped_collection
      super.includes :a_crm_status
    end
  end

end
