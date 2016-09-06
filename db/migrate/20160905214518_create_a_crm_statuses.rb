class CreateACrmStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_statuses, :id => false, :primary_key => :code do |t|
      t.string :code, null: false
      t.string :name
      t.boolean :is_active
      t.string :crm_group_id, foreign_key: true

      t.timestamps
      t.index :code, unique: true
      t.index :crm_group_id
    end
  end
end
