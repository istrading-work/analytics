class CreateACrmUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :a_crm_users, id:false do |t|
	  t.integer :id
  	  t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :is_manager
      t.boolean :is_active

      t.timestamps
	  t.index :id, unique: true
    end
  end
end
