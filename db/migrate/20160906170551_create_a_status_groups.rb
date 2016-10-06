class CreateAStatusGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :a_status_groups do |t|
      t.string :name, null: false
      
      t.index :name, unique: true
    end
  end
end
