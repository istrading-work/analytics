class CreateACrmRefUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_ref_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :is_manager
      t.boolean :is_active
      t.integer :crm_user_id

      t.timestamps
    end
  end
end
