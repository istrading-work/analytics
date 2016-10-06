class CreateACrmHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_histories do |t|
      t.datetime :dt
      t.references :a_crm_order,     foreign_key: true
      t.string     :a_crm_status_id, foreign_key: true
      t.timestamps
      t.index :a_crm_status_id
    end
  end
end
