# == Schema Information
#
# Table name: a_post_histories
#
#  id             :integer          not null, primary key
#  dt             :datetime
#  status         :string
#  pd_index       :string
#  pd_desc        :string
#  op_type        :integer
#  op_attr        :integer
#  a_crm_order_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class APostHistory < ApplicationRecord
  belongs_to :a_crm_order
  has_one :a_crm_status, through: :a_crm_order
  has_one :a_status_group, through: :a_crm_order
  
  scope :default, -> { order ('dt desc')}

  scope :ret, -> {
    joins(:a_status_group)
    .where('op_type=3 and op_attr is not null and a_status_groups.name="В ПО"')
  }
  
  scope :ret2, -> {
    joins(:a_status_group)
    .where('(op_type=6 or op_type=7 or (op_type=8 and op_attr=2)) and a_status_groups.name="В ПО" and pd_index="140961"')
  }
  
  scope :wait, -> {
    joins(:a_status_group)
    .joins(:a_crm_order)
    .where('op_type=8 and op_attr=2 and a_status_groups.name="В ПО" and pd_index<>"140961"')
    .order('a_crm_orders.dt_status_updated')
  }
end
