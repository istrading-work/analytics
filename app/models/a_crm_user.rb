class ACrmUser < ApplicationRecord
  self.primary_key = 'id'
  
  def name
    "#{last_name} #{first_name}"
  end
end
