class AddPartnerToAAdminUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :a_admin_users, :partner, :boolean, default: false
  end
end
