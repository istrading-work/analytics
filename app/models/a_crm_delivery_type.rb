# == Schema Information
#
# Table name: a_crm_delivery_types
#
#  code       :string           not null, primary key
#  name       :string
#  is_active  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ACrmDeliveryType < ApplicationRecord
  self.primary_key = 'code'

  scope :active, -> { where( :is_active => true) }
  
end
