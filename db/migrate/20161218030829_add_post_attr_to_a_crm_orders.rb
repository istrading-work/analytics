class AddPostAttrToACrmOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :a_crm_orders, :post_status, :string
    add_column :a_crm_orders, :post_address, :string
  end
end
