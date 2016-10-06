# == Schema Information
#
# Table name: a_crm_status_groups
#
#  code       :string           not null, primary key
#  name       :string
#  is_active  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ACrmStatusGroup < ApplicationRecord
  self.primary_key = 'code'
end
