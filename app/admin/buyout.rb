ActiveAdmin.register_page "Buyout" do

  menu parent: "Reports", label: "Выкуп"
  
  content title: 'Выкуп' do
    panel "Filters" do
      input type:"text", name:'date1', id:"datepicker1", placeholder:"Дата заказов с..."
      input type:"text", name:'date2', id:"datepicker2", placeholder:"Дата заказов по..."
      select name:"delivery_types", 'data-placeholder':"Тип доставки...", style:"width:350px;", multiple:true, class:"chosen-select" do
        ACrmDeliveryType.active.each do |delivery_type|
          option value:"'#{delivery_type.code}'" do
            delivery_type.name
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
    
    ['Звонок совершён->Заказ отправлен',
     'Заказ отправлен->Заказ доставлен в ПО',
     'Заказ доставлен в ПО->Заказ доставлен',
     'Заказ доставлен->Заказ оплачен' 
    ].each_with_index do |v,i|
      panel v do
        div id:'spinner'+(i+1).to_s do
          status_tag 'Please wait. Loading data...'
        end
        div id: 'total'+(i+1).to_s
        div id: 'output'+(i+1).to_s, class: 'output'
      end
    end
    
  end

  page_action (:ex1) { out('reworker-2', 'reworker-7' ) }
  page_action (:ex2) { out('reworker-7', 'reworker-8' ) }
  page_action (:ex3) { out('reworker-8', 'reworker-9' ) }
  page_action (:ex4) { out('reworker-9', 'reworker-10') }

  controller do
    def out(status1, status2)
      if params[:date1].nil? && params[:date2].nil? && params[:delivery_types]==='null' && params[:shops]==='null'
        render json: ACrmHistory.report1(status1, status2)
      else
        p_date1 = params[:date1].to_s==='' ? "" : "and date(o.dt)>='#{params[:date1]}'"
        p_date2 = params[:date2].to_s==='' ? "" : "and date(o.dt)<='#{params[:date2]}'"
        p_delivery_types = params[:delivery_types]==='null' ? "" : "and o.a_crm_delivery_type_id in (#{params[:delivery_types]})"
        p_shops = params[:shops]==='null' ? "" : "and o.a_crm_shop_id in (#{params[:shops]})"
        render json: ACrmHistory.report2(status1, status2, p_date1, p_date2, p_delivery_types, p_shops)
      end
    end
  end
  
end
