# == Schema Information
#
# Table name: a_syncs
#
#  id             :integer          not null, primary key
#  kind           :string
#  page           :integer
#  total_pages    :integer
#  status         :boolean
#  a_crm_order_id :integer
#  order_index    :integer
#  total_orders   :integer
#  total_changed  :integer
#  done           :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe ASync, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
