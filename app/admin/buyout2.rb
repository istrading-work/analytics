ActiveAdmin.register_page "Buyout2" do

  menu parent: "Reports", label: "Сроки выкупа"
  
  content title: 'Сроки выкупа' do
    panel "Filters" do
      select name:"shops", 'data-placeholder':"Магазины...", style:"width:350px;", multiple:true, class:"chosen-select" do
        ACrmShop.active.each do |shop|
          option value:"'#{shop.code}'" do
            shop.name
          end          
        end
      end
      select name:"ms", 'data-placeholder':"Менеджеры...", style:"width:350px;", multiple:true, class:"chosen-select" do
        manager = ACrmUser.active_managers.each do |manager|
          option value: manager.name do
            manager.name
          end
        end
      end
      button id: 'update' do
        'Update'
      end 
    end

    panel "Сроки выкупа по месяцам" do
      div id: 'graph'
    end    

    panel "Количество выкупленных по месяцам" do
      div id: 'graph2'
    end

    panel "Сроки выкупа детально по заказам" do
     div id: 'manager'
     br     
     div id: 'graph3'
    end
    
  end

  page_action :ex do
    set_filter
    render json: ACrmOrder.report_buyout(@p_shops)
  end 

  controller do
    def set_filter
      @p_shops = params[:shops]==='null' ? "" : "and a_crm_orders.a_crm_shop_id in (#{params[:shops]})"
    end
  end
  
end
