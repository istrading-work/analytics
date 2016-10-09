ActiveAdmin.register AAdminUser do
  permit_params :email, :password, :password_confirmation, :admin

  index do
    selectable_column
    id_column
    column :email
    column :admin
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end
  
  filter :email
  filter :admin
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email if current_a_admin_user.admin?
      f.input :password
      f.input :password_confirmation
      f.input :admin if current_a_admin_user.admin?
    end
    f.actions
  end

end
