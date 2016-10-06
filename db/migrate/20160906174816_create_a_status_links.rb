class CreateAStatusLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :a_status_links do |t|
      t.string :a_crm_status_id, null: false
      t.references :a_status_group, null: false

      t.index :a_crm_status_id
    end
  end
end
