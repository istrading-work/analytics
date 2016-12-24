# == Schema Information
#
# Table name: a_crm_orders
#
#  id                     :integer          not null, primary key
#  num                    :string
#  summ                   :decimal(15, 2)
#  dt                     :datetime
#  dt_status_updated      :datetime
#  delivery_cost          :decimal(15, 2)
#  delivery_net_cost      :decimal(15, 2)
#  a_crm_status_id        :string
#  a_crm_shop_id          :string
#  a_crm_delivery_type_id :string
#  a_crm_user_id          :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  track_pochta           :string
#  post_status            :string
#  post_address           :string
#

require 'rails_helper'

RSpec.describe ACrmOrder, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
