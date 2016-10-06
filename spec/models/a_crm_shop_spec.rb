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

require 'rails_helper'

RSpec.describe ACrmShop, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
