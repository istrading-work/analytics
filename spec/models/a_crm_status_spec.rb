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

require 'rails_helper'

RSpec.describe ACrmStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
