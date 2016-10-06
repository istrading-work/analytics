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

require 'rails_helper'

RSpec.describe ACrmUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
