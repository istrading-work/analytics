class CreateAPostHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :a_post_histories do |t|
      t.datetime :dt
      t.string :status
      t.string :pd_index
      t.string :pd_desc
      t.integer :op_type
      t.integer :op_attr
      t.references :a_crm_order, foreign_key: true

      t.timestamps
    end
  end
end
