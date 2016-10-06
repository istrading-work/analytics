# == Schema Information
#
# Table name: a_status_groups
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class AStatusGroup < ApplicationRecord
  has_many :a_status_links
  has_many :a_crm_statuses, through: :a_status_links

  validates :name,
            presence: true,
            uniqueness: true
  
  before_validation do |a_status_group|
    a_status_group.name.try(:strip!)
  end
  
end
