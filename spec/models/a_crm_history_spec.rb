# == Schema Information
#
# Table name: a_crm_histories
#
#  id              :integer          not null, primary key
#  dt              :datetime
#  a_crm_order_id  :integer
#  a_crm_status_id :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  last_updated_at :datetime
#

require 'rails_helper'

RSpec.describe ACrmHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
