ActiveAdmin.register_page "Rating" do

  menu parent: "Reports", label: "Рейтинги менеджеров"

  content title: 'Рейтинги менеджеров' do
    
    columns do
      column do
        panel "Позапрошлый период" do
          table id:'before_last', class:'rating'
        end
      end
      column do
        panel "Прошлый период" do
          table id:'last', class:'rating'
        end
      end
      column do
        panel "Текущий период" do
          table id:'curr', class:'rating'
        end
      end
    end
    
  end
  page_action :ex_curr do 
    p = Period.new
    render json: ACrmUser.rate(p.begin.to_s, p.end.to_s)
  end 
  
  page_action :ex_last do
    p = Period.new.prev  
    render json: ACrmUser.rate(p.begin.to_s, p.end.to_s)
  end 

  page_action :ex_before_last do
    p = Period.new.prev.prev  
    render json: ACrmUser.rate(p.begin.to_s, p.end.to_s)
  end
  
end
