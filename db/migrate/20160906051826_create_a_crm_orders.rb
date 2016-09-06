class CreateACrmOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_orders, :id => false, :primary_key => :id do |t|
      t.integer    :id, null: false
      t.string     :num
      t.decimal    :summ, precision: 15, scale: 2
      t.datetime   :dt
      t.datetime   :dt_status_updated
      t.decimal    :delivery_cost, precision: 15, scale: 2
      t.decimal    :delivery_net_cost, precision: 15, scale: 2
      t.string     :a_crm_status_id,        foreign_key: true
      t.string     :a_crm_shop_id,          foreign_key: true
      t.string     :a_crm_delivery_type_id, foreign_key: true
      t.references :a_crm_user,             foreign_key: true

      t.timestamps
      t.index :id, unique: true
      t.index :a_crm_status_id
      t.index :a_crm_shop_id
      t.index :a_crm_delivery_type_id
    end
  end
end
