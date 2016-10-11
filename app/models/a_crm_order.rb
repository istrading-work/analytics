# == Schema Information
#
# Table name: a_crm_orders
#
#  id                     :integer          not null, primary key
#  num                    :string
#  summ                   :decimal(15, 2)
#  dt                     :datetime
#  dt_status_updated      :datetime
#  delivery_cost          :decimal(15, 2)
#  delivery_net_cost      :decimal(15, 2)
#  a_crm_status_id        :string
#  a_crm_shop_id          :string
#  a_crm_delivery_type_id :string
#  a_crm_user_id          :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ACrmOrder < ApplicationRecord
  self.primary_key = 'id'
  
  belongs_to :a_crm_status,        primary_key: 'code'
  belongs_to :a_crm_shop,          primary_key: 'code'
  belongs_to :a_crm_delivery_type, primary_key: 'code'
  belongs_to :a_crm_user
  has_one :a_status_group, through: :a_crm_status
  has_many :a_crm_history

  scope :report2, -> {
    joins(:a_status_group)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('date(a_crm_orders.dt) as dt, a_status_groups.name as status, a_crm_shops.name as shop, a_crm_users.last_name as manager, count(*) as total_count, sum(a_crm_orders.summ-delivery_cost) as total_sum')
   .group('date(a_crm_orders.dt)','a_crm_users.last_name','a_status_groups.name', 'a_crm_shops.name' )
   .order('date(a_crm_orders.dt) desc','a_status_groups.id asc' )
  }
  
  scope :report3, -> (p_date1, p_date2, p_managers, p_shops ) {
    joins(:a_status_group)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select(
     'strftime("%d/%m", a_crm_orders.dt) as dt1,
     a_crm_users.last_name || " " || a_crm_users.first_name  as manager,
     a_crm_shops.name as shop,
     count(*) as total_count, 
     sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) as approve_count,
     sum(case when a_status_groups.name in ("Выкуплен","Оплачен") then 1 else 0 end) as buy_count,
     sum(case when a_status_groups.name in ("Возврат") then 1 else 0 end) as ret_count,
     sum(case when a_status_groups.name="Отмена" then 1 else 0 end) as cancel_count, 
     sum(case when a_status_groups.name="Холд" then 1 else 0 end) as hold_count, 
     sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-delivery_cost else 0 end)/sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) as ch'
    )
   .where("a_crm_users.is_active='t' and a_crm_users.is_manager='t' #{p_date1} #{p_date2} #{p_managers} #{p_shops}"  )
   .group('date(a_crm_orders.dt)', 'shop', 'manager' )
   .order('date(a_crm_orders.dt)', 'manager', 'shop' )
  }

  scope :report4, -> (p_date1, p_date2, p_managers, p_shops ) {
    joins(:a_status_group)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select(
     'a_crm_users.last_name || " " || a_crm_users.first_name as manager,
     a_crm_shops.name as shop,
     count(*) as total_count,
     sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) as approve_count,
     sum(case when a_status_groups.name in ("Выкуплен","Оплачен") then 1 else 0 end) as buy_count,
     sum(case when a_status_groups.name in ("Возврат") then 1 else 0 end) as ret_count,
     sum(case when a_status_groups.name="Отмена" then 1 else 0 end) as cancel_count, 
     sum(case when a_status_groups.name="Холд" then 1 else 0 end) as hold_count,
     case when sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) == 0 then 0 else round((sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-delivery_cost else 0 end)+0.0)/sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end),0) end as ch,
     sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-delivery_cost else 0 end) as approve_sum'
    )
   .where("a_crm_users.is_active='t' and a_crm_users.is_manager='t' #{p_date1} #{p_date2} #{p_managers} #{p_shops}"  )
   .group('shop', 'manager' )
   .order('manager', 'shop' )
  }  
end
