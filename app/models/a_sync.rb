# == Schema Information
#
# Table name: a_syncs
#
#  id             :integer          not null, primary key
#  kind           :string
#  page           :integer
#  total_pages    :integer
#  status         :boolean
#  a_crm_order_id :integer
#  order_index    :integer
#  total_orders   :integer
#  total_changed  :integer
#  done           :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ASync < ApplicationRecord

  scope :last_syncs, -> {
    from(
      '(
      select * from (SELECT * FROM "a_syncs" WHERE kind = "history" order by id desc limit 1)  
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "orders" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "users" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "shops" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "statuses" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "status-groups" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "delivery-types" order by id desc limit 1)
      ) "a_syncs"
    ')
  }  
end
