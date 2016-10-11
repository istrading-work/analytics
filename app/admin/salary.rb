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
          br
          select name:"detail", style:"width:350px;", class:"chosen-select" do
            [
              { title: 'По дням',    v: 'day' },
              { title: 'По неделям', v: 'week' },
              { title: 'По месяцам', v: 'month'},
            ].each do |p|
              option value: p[:v] do
                p[:title]
              end
            end          
          end          
        end
        column span:2 do
          if current_a_admin_user.admin?
            select name:"managers", 'data-placeholder':"Менеджеры...", style:"width:350px;", multiple:true, class:"chosen-select" do
              ACrmUser.active_managers.each do |manager|
                option value:"'#{manager.id}'" do
                  manager.name
                end          
              end
            end
          else
            select name:"managers", 'data-placeholder':"Менеджеры...", style:"width:350px;", multiple:true, class:"chosen-select", disabled:true do
              manager = ACrmUser.find_by(email: current_a_admin_user.email)
              option value:"'#{manager.id}'", selected:true do
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
    
    if current_a_admin_user.admin?
      panel "График" do
        select name:"ms", 'data-placeholder':"Менеджеры...", style:"width:350px;", multiple:true, class:"chosen-select" do
          manager = ACrmUser.active_managers.each do |manager|
            option value: manager.name do
              manager.name
            end
          end
        end
        
        select name:"ss", 'data-placeholder':"Магазины...", style:"width:350px;", class:"chosen-select" do
          ACrmShop.active.each do |shop|
            option value: shop.name do
              shop.name
            end          
          end
        end
          
        select name:"p", 'data-placeholder':"Параметр...", style:"width:350px;", class:"chosen-select" do
          [
            { title: 'Всего заказов', v: 'total_count' },
            { title: 'Апрув',         v: 'approve_count' },
            { title: 'Выкуплен',      v: 'buy_count'},
            { title: 'Возврат',       v: 'ret_count' },
            { title: 'Отмена',        v: 'cancel_count' },
            { title: 'Холд',          v: 'hold_count' },
            { title: 'Ср.чек',        v: 'ch' },
            { title: 'Апрув(%)',      v: 'ap' },
            { title: 'Выкуплен(%)',   v: 'bp' },
            { title: 'Возврат(%)',    v: 'rp' },
            { title: 'Выполнен(%)',   v: 'brp' },
            { title: 'Опл/заказ',     v: 'z' },
            { title: 'Оплата',        v: 'z_total' }
          ].each do |p|
            option value: p[:v] do
              p[:title]
            end
          end          
        end
          
  
        button id: 'update_gr' do
          'Update'
        end  
        div id: 'graph'
      end    
    end
    
    panel "Свод по менеджерам" do
      table id:'output1', class:"compact"
    end
    
    if current_a_admin_user.admin?
      panel "Свод по магазинам" do
        table id:'output2', class:"compact"
      end
    end
    
    panel "Детали" do
      table id:'output' , class:"compact"
    end
    
  end

  page_action :ex_day do 
    set_filter
    render json: ACrmOrder.salary_report_day(@p_date1, @p_date2, @p_managers, @p_shops)
  end 

  page_action :ex_week do 
    set_filter
    render json: ACrmOrder.salary_report_week(@p_date1, @p_date2, @p_managers, @p_shops)
  end

  page_action :ex_month do 
    set_filter
    render json: ACrmOrder.salary_report_month(@p_date1, @p_date2, @p_managers, @p_shops)
  end

  page_action :ex_total do 
    set_filter
    render json: ACrmOrder.salary_report_total(@p_date1, @p_date2, @p_managers, @p_shops)
  end 
  
  controller do
    def set_filter
      @p_date1 = params[:date1].to_s==='' ? "" : "and date(a_crm_orders.dt)>='#{DateTime.parse(params[:date1]).utc.to_date}'"
      @p_date2 = params[:date2].to_s==='' ? "" : "and date(a_crm_orders.dt)<='#{DateTime.parse(params[:date2]).utc.to_date}'"
      @p_managers = params[:managers]==='null' ? "" : "and a_crm_orders.a_crm_user_id in (#{params[:managers]})"
      @p_shops = params[:shops]==='null' ? "" : "and a_crm_orders.a_crm_shop_id in (#{params[:shops]})"
    end
  end
  
end
