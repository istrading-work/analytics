ActiveAdmin.register APostHistory do

  menu parent: "CRM Data"

  config.batch_actions = false
  actions :index, :show
  
  index do |el|
    column :a_crm_order_id do |t|
      link_to "#{t.a_crm_order_id}", "https://reprisa.retailcrm.ru/orders/#{t.a_crm_order_id}/edit"
    end
    column :a_crm_order do |t|
      t.a_crm_order.num
      link_to "#{t.a_crm_order.num}", "http://istrading.ru:3000/orders/#{t.a_crm_order.num}"
    end
    column :a_crm_order do |t|
      t.a_crm_order.a_status_group
    end
    column :order_dt do |t|
      t.a_crm_order.dt
    end
    column :a_crm_order do |t|
      t.a_crm_order.dt_status_updated
    end
    column :a_crm_status
    column :dt
    column :status
    column :pd_index
    column :pd_desc
    column :op_type
    column :op_attr
    column :created_at   
  end
  
  filter :a_crm_order_id
  filter :op_type
  filter :op_attr
  
  scope :all
  scope :wait
  scope :ret, :default=> true

  controller do
    def scoped_collection
      super.includes :a_crm_order, :a_crm_status
    end
  end
  
end
