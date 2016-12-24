class AddTrackPochtaToACrmOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :a_crm_orders, :track_pochta, :string
  end
end
