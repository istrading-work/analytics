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
#  track_pochta           :string
#  post_status            :string
#  post_address           :string
#

class ACrmOrder < ApplicationRecord
  self.primary_key = 'id'
  
  belongs_to :a_crm_status,        primary_key: 'code'
  belongs_to :a_crm_shop,          primary_key: 'code'
  belongs_to :a_crm_delivery_type, primary_key: 'code'
  belongs_to :a_crm_user
  has_one :a_status_group, through: :a_crm_status
  has_one :a_crm_status_group, through: :a_crm_status
  has_many :a_crm_history
  has_many :a_post_history
  
  scope :russian_post, -> { where( :a_crm_delivery_type_id => 'russian-post' ) }
  scope :with_track, -> { where.not( track_pochta: nil ) }
  scope :in_post, -> {
    joins(:a_status_group)
    .where( 'a_status_groups.name' => 'В ПО' )
  }
  
  scope :report2, -> {
    joins(:a_status_group)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('date(a_crm_orders.dt) as dt, a_status_groups.name as status, a_crm_shops.name as shop, a_crm_users.last_name as manager, count(*) as total_count, sum(a_crm_orders.summ-delivery_cost) as total_sum')
   .group('date(a_crm_orders.dt)','a_crm_users.last_name','a_status_groups.name', 'a_crm_shops.name' )
   .order('date(a_crm_orders.dt) desc','a_status_groups.id asc' )
  }

query = <<-SQL 
  a_crm_users.last_name || " " || a_crm_users.first_name  as manager,
  a_crm_shops.name as shop,
  count(*) as total_count, 
  sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) as approve_count,
  sum(case when a_status_groups.name not in ("Холд","Отмена") or a_crm_statuses.crm_group_id="validation" or a_crm_orders.a_crm_status_id = 'cancel-after-complete' then 1 else 0 end) as approve2_count,
  sum(case when a_status_groups.name in ("Выкуплен","Оплачен") then 1 else 0 end) as buy_count,
  sum(case when a_status_groups.name in ("В ПО") then 1 else 0 end) as po_count,
  sum(case when a_status_groups.name in ("Возврат") then 1 else 0 end) as ret_count,
  sum(case when a_status_groups.name="Отмена" then 1 else 0 end) as cancel_count,
  sum(case when a_status_groups.name in ("В пути") then 1 else 0 end) as pt_count,  
  sum(case when a_status_groups.name in ("Принят") then 1 else 0 end) as accept_count,  
  sum(case when a_status_groups.name="Холд" then 1 else 0 end) as hold_count, 
  case when sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) == 0 then 0 else round((sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-a_crm_orders.delivery_cost else 0 end)+0.0)/sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end),0) end as ch,
  sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-delivery_cost else 0 end) as approve_sum,
  sum(case when a_status_groups.name in ("Выкуплен","Оплачен") then a_crm_orders.summ-delivery_cost else 0 end) as buy_sum
SQL

query_sales = <<-SQL 
  a_crm_shops.name as shop,
  count(*) as total_count, 
  sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) as approve_count,
  sum(case when a_status_groups.name not in ("Холд","Отмена") or a_crm_statuses.crm_group_id="validation" or a_crm_orders.a_crm_status_id = 'cancel-after-complete' then 1 else 0 end) as approve2_count,
  sum(case when a_status_groups.name in ("Выкуплен","Оплачен") then 1 else 0 end) as buy_count,
  sum(case when a_status_groups.name in ("Возврат") then 1 else 0 end) as ret_count,
  sum(case when a_status_groups.name="Отмена" then 1 else 0 end) as cancel_count, 
  sum(case when a_status_groups.name="Холд" then 1 else 0 end) as hold_count, 
  case when sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end) == 0 then 0 else round((sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-a_crm_orders.delivery_cost else 0 end)+0.0)/sum(case when a_status_groups.name not in ("Холд","Отмена") then 1 else 0 end),0) end as ch,
  sum(case when a_status_groups.name not in ("Холд","Отмена") then a_crm_orders.summ-delivery_cost else 0 end) as approve_sum,
  sum(case when a_status_groups.name in ("Выкуплен","Оплачен") then a_crm_orders.summ-delivery_cost else 0 end) as buy_sum
SQL

query_distribution = <<-SQL
  SELECT count(*) as cnt, round(sum(summ-delivery_cost)/count(*),0)
SQL
  
  scope :salary_report_day, -> (p_date1, p_date2, p_managers, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('date(dt) as dt1,' + query)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_managers} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('dt1', 'shop', 'manager' )
   .order('dt1', 'manager', 'shop' )
  }

  scope :sales_report_day, -> (p_date1, p_date2, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('date(dt) as dt1,' + query_sales)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('dt1', 'shop')
   .order('dt1', 'shop' )
  }
  
  scope :salary_report_week, -> (p_date1, p_date2, p_managers, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('strftime( "%W", dt ) as dt1,' + query)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru')  #{p_date1} #{p_date2} #{p_managers} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('dt1', 'shop', 'manager' )
   .order('dt1', 'manager', 'shop' )
  }

  scope :sales_report_week, -> (p_date1, p_date2, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('strftime( "%W", dt ) as dt1,' + query_sales)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('dt1', 'shop')
   .order('dt1', 'shop' )
  }
  
  scope :salary_report_month, -> (p_date1, p_date2, p_managers, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('strftime( "%m", dt ) as dt1,' + query)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_managers} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('dt1', 'shop', 'manager' )
   .order('dt1', 'manager', 'shop' )
  }

  scope :sales_report_month, -> (p_date1, p_date2, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('strftime( "%m", dt ) as dt1,' + query_sales)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('dt1', 'shop',)
   .order('dt1', 'shop' )
  }
  
  scope :salary_report_total, -> (p_date1, p_date2, p_managers, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select(query)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_managers} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('shop', 'manager' )
   .order('manager', 'shop' )
  }

  scope :sales_report_total, -> (p_date1, p_date2, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_status)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select(query_sales)
   .where("(a_crm_users.email <> 'ksenia@istrading.ru') #{p_date1} #{p_date2} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('shop')
   .order('shop' )
  }
  
  scope :distribution, ->  (p_date1, p_date2, p_managers, p_shops, p_ch1, p_ch2 ) {
    joins(:a_status_group)
   .joins(:a_crm_shop)
   .joins(:a_crm_user)
   .select('count(*) as cnt, round(100*sum(summ-delivery_cost)/count(*)/100.0,0) as ch')
   .where("a_status_groups.name not in ('Холд','Отмена') #{p_date1} #{p_date2} #{p_managers} #{p_shops} #{p_ch1} #{p_ch2}"  )
   .group('round((summ-delivery_cost)/100.0,0)')
   .order('ch')   
  }

  scope :report_buyout, -> (p_shops) {
    connection.select_all(
"select
a_crm_orders.id,
a_crm_orders.a_crm_shop_id,
a_crm_users.id as user_id,
a_crm_users.last_name || ' ' || a_crm_users.first_name  as manager,
a_crm_orders.dt,
strftime( '%Y %m', a_crm_orders.dt ) as dto,
round(julianday(a_crm_histories.dt)-julianday(a_crm_orders.dt)) as srok_vikupa,
a_crm_histories.a_crm_status_id
from a_crm_orders
join a_crm_users on a_crm_users.id=a_crm_orders.a_crm_user_id
join a_status_links a1 on a1.a_crm_status_id=a_crm_orders.a_crm_status_id
join a_status_groups b1 on b1.id=a1.a_status_group_id
join a_crm_histories on a_crm_histories.a_crm_order_id=a_crm_orders.id
join a_status_links a2 on a2.a_crm_status_id=a_crm_histories.a_crm_status_id
join a_status_groups b2 on b2.id=a2.a_status_group_id
where 
(b1.name='Выкуплен' or b1.name='Оплачен') and
(b2.name='Выкуплен' or b2.name='Оплачен')
#{p_shops}
except
select
a_crm_orders.id,
a_crm_orders.a_crm_shop_id,
a_crm_users.id as user_id,
a_crm_users.last_name || ' ' || a_crm_users.first_name  as manager,
a_crm_orders.dt,
strftime( '%Y %m', a_crm_orders.dt ) as dto,
round(julianday(a_crm_histories.dt)-julianday(a_crm_orders.dt)) as srok_vikupa,
a_crm_histories.a_crm_status_id
from a_crm_orders
join a_crm_users on a_crm_users.id=a_crm_orders.a_crm_user_id
join a_status_links a1 on a1.a_crm_status_id=a_crm_orders.a_crm_status_id
join a_status_groups b1 on b1.id=a1.a_status_group_id
join a_crm_histories on a_crm_histories.a_crm_order_id=a_crm_orders.id
join a_status_links a2 on a2.a_crm_status_id=a_crm_histories.a_crm_status_id
join a_status_groups b2 on b2.id=a2.a_status_group_id
where 
(b1.name='Выкуплен' or b1.name='Оплачен') and
(b1.name='Оплачен' and b2.name='Выкуплен')
#{p_shops}
order by a_crm_orders.dt"
    )
  }
  
  scope :by_period, -> (p_date1, p_date2) {
    where("dt>='#{p_date1}' and dt<='#{p_date2}'")
  }

  scope :by_shop, -> (shop) {
    where(a_crm_shop: shop)
  }
  
  scope :total_count, -> {
    joins(:a_status_group)
  }

  scope :approve_count, -> {
    joins(:a_status_group)
    .where('a_status_groups.name not in ("Холд","Отмена")')
  }

  scope :approve2_count, -> {
    joins(:a_status_group)
    .where('a_status_groups.name not in ("Холд","Отмена") or a_crm_statuses.crm_group_id="validation" or a_crm_orders.a_crm_status_id = "cancel-after-complete"')
  }
  
  def self.rate(p_date1, p_date2)
    dt=Time.parse(p_date1)
    dt1=dt.beginning_of_day.utc
    dt2=Time.parse(p_date2).end_of_day.utc
    
    dt1p=(dt-60.days).beginning_of_day.utc
    dt2p=dt.end_of_day.utc
    
    s_ave = sales_report_total("and a_crm_orders.dt>='#{dt1}'", "and a_crm_orders.dt<='#{dt2}'", "", "", "" )
    s_ave_prev = sales_report_total("and a_crm_orders.dt>='#{dt1p}'", "and a_crm_orders.dt<='#{dt2p}'", "", "", "" )
    
    st = {}
    s_ave.each do |t|
      st[t.shop] = {} unless st.has_key?(t.shop)
      st[t.shop]['total_count'] = t.total_count
      st[t.shop]['ap'] = (t.approve_count+0.0)/t.total_count
      st[t.shop]['a2p'] = (t.approve2_count+0.0)/t.total_count
      st[t.shop]['bp'] = 0
      ch = 0
      ch = t.approve_sum/t.approve_count if t.approve_count>0
      st[t.shop]['ch'] = ch
      bch = 0
      bch = t.buy_sum/t.buy_count if t.buy_count>0      
      st[t.shop]['bch'] = bch
      st[t.shop]['bch_prev'] = 0
      st[t.shop]['approve_count'] = t.approve_count
    end
    
    s_ave_prev.each do |t|
      if st.has_key?(t.shop)
        st[t.shop]['bp'] = (t.buy_count+0.0)/t.approve_count if t.approve_count>0
        bch_prev = 0
        bch_prev = t.buy_sum/t.buy_count if t.buy_count>0      
        st[t.shop]['bch_prev'] = bch_prev
      end        
    end
    
    st
  end
  
end
