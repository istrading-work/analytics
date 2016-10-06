ActiveAdmin.register AStatusLink do
  permit_params :a_status_group_id, :a_crm_status_id 

  menu parent: "Analytics Data" 
  config.batch_actions = false
  
  index do
    id_column
    column :a_status_group
    column :a_crm_status_group do |el|
      el.a_crm_status.crm_group.name
    end
    column :a_crm_status

    actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :a_crm_status \
              , :as => :select \
              , :collection => ACrmStatus.includes([:crm_group]).without_analytics_group.order("a_crm_status_groups.name").map { 
                   |s| ["#{s.crm_group.name} | #{s.name}", s.code]
              }
      f.input :a_status_group
    end
    f.actions
  end

end
