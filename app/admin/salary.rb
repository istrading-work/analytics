ActiveAdmin.register_page "Salary" do

  menu parent: "Reports", label: "Статистика продаж и начисления ЗП"
  
  content title: 'Статистика продаж и начисления ЗП' do
    panel "Filters" do
      columns do
        column do
          input type:"text", name:'date1', id:"datepicker1", placeholder:"Дата заказов с..."
          input type:"text", name:'date2', id:"datepicker2", placeholder:"Дата заказов по..."
          br
          span id:"curr" do
            'текущий'
          end
          span id:"prev" do
            'предыдущий'
          end        
        end
        column span:2 do
          select name:"managers", 'data-placeholder':"Менеджеры...", style:"width:350px;", multiple:true, class:"chosen-select" do
            ACrmUser.active_managers.each do |manager|
              option value:"'#{manager.id}'" do
                manager.name
              end          
            end
          end
          select name:"shops", 'data-placeholder':"Магазины...", style:"width:350px;", multiple:true, class:"chosen-select" do
            ACrmShop.active.each do |shop|
              option value:"'#{shop.code}'" do
                shop.name
              end          
            end
          end
          button id: 'update' do
            'Update'
          end        
        end
      end


    end
    panel "Свод по менеджерам" do
      table id:'output1', class:"compact"
    end
    panel "Свод по магазинам" do
      table id:'output2', class:"compact"
    end
    panel "Детали" do
      table id:'output' , class:"compact"
    end
    
  end

  page_action :ex do 
    set_filter
    render json: ACrmOrder.report3(@p_date1, @p_date2, @p_managers, @p_shops)
  end

  page_action :ex2 do 
    set_filter
    render json: ACrmOrder.report4(@p_date1, @p_date2, @p_managers, @p_shops)
  end  

  controller do
    def set_filter
      @p_date1 = params[:date1].to_s==='' ? "" : "and a_crm_orders.dt>='#{params[:date1]}'"
      @p_date2 = params[:date2].to_s==='' ? "" : "and a_crm_orders.dt<='#{params[:date2]}'"
      @p_managers = params[:managers]==='null' ? "" : "and a_crm_orders.a_crm_user_id in (#{params[:managers]})"
      @p_shops = params[:shops]==='null' ? "" : "and a_crm_orders.a_crm_shop_id in (#{params[:shops]})"
    end
  end
  
end
