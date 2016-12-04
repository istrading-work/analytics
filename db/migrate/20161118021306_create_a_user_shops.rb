class CreateAUserShops < ActiveRecord::Migration[5.0]
  def change
    create_table :a_user_shops do |t|
      t.references :a_admin_user, null: false
      t.string :a_crm_shop_id, null: false

      t.index :a_crm_shop_id
    end
  end
end
