class CreateACrmStatusGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_status_groups, :id => false, :primary_key => :code do |t|
      t.string :code, null: false
      t.string :name
      t.boolean :is_active

      t.timestamps
      t.index :code, unique: true
    end
  end
end
