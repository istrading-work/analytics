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

  scope :all
  
  scope :today, :default=> true do |orders|
    orders.where("date(dt) = date('now')")
  end
  
end
