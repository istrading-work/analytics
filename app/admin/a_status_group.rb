ActiveAdmin.register AStatusGroup do
  permit_params :name

  menu parent: "Analytics Data" 
  
  config.batch_actions = false
  before_filter :skip_sidebar!, :only => :index
  
  index do
    id_column
    column :name
    actions
  end

end
