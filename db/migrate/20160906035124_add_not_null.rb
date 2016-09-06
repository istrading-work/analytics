class AddNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:a_crm_users, :id, false)
    change_column_null(:a_crm_shops, :code, false)
    change_column_null(:a_crm_delivery_types, :code, false)    
  end
end
