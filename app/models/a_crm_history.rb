# == Schema Information
#
# Table name: a_crm_histories
#
#  id              :integer          not null, primary key
#  dt              :datetime
#  a_crm_order_id  :integer
#  a_crm_status_id :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  last_updated_at :datetime
#

class ACrmHistory < ApplicationRecord
  belongs_to :a_crm_order
  belongs_to :a_crm_status, primary_key: 'code'

  scope :report1, -> (status1, status2){
    connection.select_all("select round(julianday(h2.dt)-julianday(h1.dt)) as delta, count(*) as k from a_crm_histories h1 inner join a_crm_histories h2 indexed by index_a_crm_histories_on_a_crm_order_id on h2.a_crm_order_id=h1.a_crm_order_id where h1.a_crm_status_id='#{status1}' and h2.a_crm_status_id='#{status2}' group by delta order by delta")
  }

  scope :report2, -> (status1, status2, p_date1, p_date2, p_delivery_types, p_shops ){
    connection.select_all("select round(julianday(h2.dt)-julianday(h1.dt)) as delta, count(*) as k from a_crm_histories h1 inner join a_crm_histories h2 indexed by index_a_crm_histories_on_a_crm_order_id on h2.a_crm_order_id=h1.a_crm_order_id join a_crm_orders o on h2.a_crm_order_id=o.id where h1.a_crm_status_id='#{status1}' and h2.a_crm_status_id='#{status2}' #{p_date1} #{p_date2} #{p_delivery_types} #{p_shops} group by delta order by delta")
  }
  
end
