class AddAdminToAAdminUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :a_admin_users, :admin, :boolean, default: false
  end
end
