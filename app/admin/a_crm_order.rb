ActiveAdmin.register ACrmOrder do

  menu parent: "CRM Data"

  config.batch_actions = false
  actions :index, :show

  index do |el|
    column :id do |order|
      link_to "#{order.id}", "https://reprisa.retailcrm.ru/orders/#{order.id}/edit"
    end
    column :num
    column :dt
    column :dt_status_updated
    column :a_status_group
    column :a_crm_status
    column :a_crm_shop
    column :summ
    column :a_crm_user
    actions
  end

  show do
    panel "History" do
      table_for a_crm_order.a_crm_history do
        column :id
        column :dt
        column :a_crm_status
        column :last_updated_at
      end
    end
    attributes_table do
      row :id do |order|
        link_to "#{order.id}", "https://reprisa.retailcrm.ru/orders/#{order.id}/edit"
      end
      row :a_crm_shop
      row :num
      row :dt
      row :dt_status_updated
      row :a_status_group
      row :a_crm_status
      row :summ
      row :a_crm_user
    end
  end

  scope :all
  
  scope :today, :default=> true do |orders|
    orders.where("date(dt) = date('now')")
  end

  controller do
    def scoped_collection
      super.includes :a_status_group, :a_crm_status, :a_crm_status, :a_crm_shop, :a_crm_user
    end
  end

end
