# == Schema Information
#
# Table name: a_post_histories
#
#  id             :integer          not null, primary key
#  dt             :datetime
#  status         :string
#  pd_index       :string
#  pd_desc        :string
#  op_type        :integer
#  op_attr        :integer
#  a_crm_order_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe APostHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
