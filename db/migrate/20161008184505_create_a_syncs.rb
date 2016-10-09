class CreateASyncs < ActiveRecord::Migration[5.0]
  def change
    create_table :a_syncs do |t|
      t.string :kind
      t.integer :page
      t.integer :total_pages
      t.boolean :status
      t.references :a_crm_order
      t.integer :order_index
      t.integer :total_orders
      t.integer :total_changed
      t.boolean :done
      
      t.timestamps
    end
  end
end
