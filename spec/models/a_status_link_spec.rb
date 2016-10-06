# == Schema Information
#
# Table name: a_status_links
#
#  id                :integer          not null, primary key
#  a_crm_status_id   :string           not null
#  a_status_group_id :integer          not null
#

require 'rails_helper'

RSpec.describe AStatusLink, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
