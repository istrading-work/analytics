class CreateACrmShops < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_shops, id:false do |t|
      t.string :code
      t.string :name
      t.boolean :is_active

      t.timestamps
      t.index :code, unique: true
    end
  end
end
