# == Schema Information
#
# Table name: a_crm_statuses
#
#  code         :string           not null, primary key
#  name         :string
#  is_active    :boolean
#  crm_group_id :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ACrmStatus < ApplicationRecord
  self.primary_key = 'code'
  
  belongs_to :crm_group, class_name: 'ACrmStatusGroup', primary_key: 'code'
  has_one :a_status_link
  has_one :a_status_group, through: :a_status_link
  
  scope :active, -> { where( :is_active => true) }

  scope :without_analytics_group, -> {
    left_outer_joins(:a_status_group)
   .where("a_status_groups.id is null")
  }

end
