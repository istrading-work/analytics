class ACrmStatus < ApplicationRecord
  self.primary_key = 'code'
  belongs_to :crm_group, class_name: 'ACrmStatusGroup', primary_key: 'code'
end
