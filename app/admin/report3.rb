ActiveAdmin.register_page "Report3" do

  menu parent: "Reports", label: "Конструктор"

  action_item do
    link_to "JSON", admin_report3_ex_path
  end
  
  content title: 'Report3' do
    div class:'spinner' do
      status_tag 'Please wait. Loading data...'
    end
    
    div class:'test test1'
    div class:'test test3'
  end

  page_action (:ex) { render json: ACrmOrder.report2 }
  
end
