# == Schema Information
#
# Table name: a_user_shops
#
#  id              :integer          not null, primary key
#  a_admin_user_id :integer          not null
#  a_crm_shop_id   :string           not null
#

require 'rails_helper'

RSpec.describe AUserShop, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
