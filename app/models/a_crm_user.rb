# == Schema Information
#
# Table name: a_crm_users
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  email      :string
#  is_manager :boolean
#  is_active  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ACrmUser < ApplicationRecord
  self.primary_key = 'id'
  
  def name
    "#{last_name} #{first_name}"
  end
  
  scope :active, -> { where( :is_active => true) }

  scope :active_managers, -> { where( :is_active => true, :is_manager => true) }
  
end
