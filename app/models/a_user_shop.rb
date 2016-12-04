# == Schema Information
#
# Table name: a_user_shops
#
#  id              :integer          not null, primary key
#  a_admin_user_id :integer          not null
#  a_crm_shop_id   :string           not null
#

class AUserShop < ApplicationRecord
  belongs_to :a_crm_shop, primary_key: 'code'
  belongs_to :a_admin_user
end
