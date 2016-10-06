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

  scope :active, -> { where( :is_active => true) }

end
