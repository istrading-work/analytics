class AUserShop < ApplicationRecord
  belongs_to :a_crm_shop, primary_key: 'code'
  belongs_to :a_admin_user
end
