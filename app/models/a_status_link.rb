# == Schema Information
#
# Table name: a_status_links
#
#  id                :integer          not null, primary key
#  a_crm_status_id   :string           not null
#  a_status_group_id :integer          not null
#

class AStatusLink < ApplicationRecord
  belongs_to :a_crm_status, primary_key: 'code'
  belongs_to :a_status_group
  
  validates_presence_of :a_crm_status_id, :a_status_group_id
  validates_uniqueness_of :a_crm_status_id
end
