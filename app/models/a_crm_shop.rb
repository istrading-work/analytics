# == Schema Information
#
# Table name: a_crm_shops
#
#  code       :string           not null, primary key
#  name       :string
#  is_active  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ACrmShop < ApplicationRecord
  self.primary_key = 'code'
  
  has_many :a_user_shop
  has_many :a_admin_users, through: :a_user_shop  
  
  scope :active, -> { where( :is_active => true) }
  
  scope :by_user, -> (p_user_id) {
    joins(:a_admin_users)
   .where("a_admin_users.id = #{p_user_id}")
  }
  
end
