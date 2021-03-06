ActiveAdmin.register_page "Salary" do

  menu parent: "Reports", label: "Статистика продаж и начисления ЗП"

  content title: 'Статистика продаж и начисления ЗП' do
    div id:'headerstat', class:'headerstat' do
      table id:'ht' do
      end
    end
    
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
          br
          br
          input type:"text", name:'ch1', id:"ch1", placeholder:"Чек заказов с..."
          input type:"text", name:'ch2', id:"ch2", placeholder:"Чек заказов по..."          
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
              ACrmUser.active_managers.each do |manager|
                option value:"'#{manager.id}'" do
                  manager.name
                end          
              end
              #manager = ACrmUser.find_by(email: current_a_admin_user.email)
              #option value:"'#{manager.id}'", selected:true do
              #  manager.name
              #end
            end
            manager = ACrmUser.find_by(email: current_a_admin_user.email)
            div id: 'manager_name', hidden:true do
              manager.name
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
      panel "График распределения кол-во заказов = func (чек)" do
        div id: 'graph_distribution'
      end
    
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
            { title: 'Выкуп',      v: 'buy_count'},
            { title: 'Возврат',       v: 'ret_count' },
            { title: 'Отмена',        v: 'cancel_count' },
            { title: 'Холд',          v: 'hold_count' },
            { title: 'Ср.чек',        v: 'ch' },
            { title: 'Ср.чек выкуп',  v: 'bch' },
            { title: 'Апрув(%)',      v: 'ap' },
            { title: 'Выкуп(%)',   v: 'bp' },
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
=begin
    panel "Колонки показать/скрыть" do
      columns = [
        { title: 'Всего' },
        { title: 'Апрув' },
        { title: 'Апрув +' },
        { title: 'Выкуп' },
        { title: 'В ПО' },
        { title: 'Возврат' },
        { title: 'Отмена' },
        { title: 'Путь' },
        { title: 'Принят' },
        { title: 'Холд' },
        { title: 'Ср.чек' },
        { title: 'Ср.чек выкуп' },
        { title: 'Апрув(%)' },
        { title: 'Апрув +(%)' },
        { title: 'Выкуп(%)' },
        { title: 'Выкуп +(%)' },
        { title: 'Возврат(%)' },
        { title: 'Выполнен(%)' },
        { title: 'Опл/заказ' },
        { title: 'Оплата' },
        { title: 'km' },
        { title: 'ka' },
        { title: 'ka2' },
        { title: 'kb' }
      ]
      
      columns.each_with_index do |v,i|
        input type:"checkbox", checked:true, id:"b#{i}"
        label for:"b#{i}" do
          v[:title]
        end
      end
      button id: 'update_col' do
        'Update'
      end  
    end
=end
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
    render json: ACrmOrder.salary_report_day(@p_date1, @p_date2, @p_managers, @p_shops, @p_ch1, @p_ch2)
  end 

  page_action :ex_week do 
    set_filter
    render json: ACrmOrder.salary_report_week(@p_date1, @p_date2, @p_managers, @p_shops, @p_ch1, @p_ch2)
  end

  page_action :ex_month do 
    set_filter
    render json: ACrmOrder.salary_report_month(@p_date1, @p_date2, @p_managers, @p_shops, @p_ch1, @p_ch2)
  end

  page_action :ex_total do 
    set_filter
    render json: ACrmOrder.salary_report_total(@p_date1, @p_date2, @p_managers, @p_shops, @p_ch1, @p_ch2)
  end 

  page_action :ex_distribution do 
    set_filter
    render json: ACrmOrder.distribution(@p_date1, @p_date2, @p_managers, @p_shops, @p_ch1, @p_ch2)
  end 
  
  controller do
    def set_filter
      @p_date1 = params[:date1].to_s==='' ? "" : "and a_crm_orders.dt>='#{Time.parse(params[:date1]).beginning_of_day.utc}'"
      @p_date2 = params[:date2].to_s==='' ? "" : "and a_crm_orders.dt<='#{Time.parse(params[:date2]).end_of_day.utc}'"
      @p_managers = params[:managers]==='null' ? "" : "and a_crm_orders.a_crm_user_id in (#{params[:managers]})"
      @p_shops = params[:shops]==='null' ? "" : "and a_crm_orders.a_crm_shop_id in (#{params[:shops]})"
      @p_ch1 = params[:ch1].to_s==='' ? "" : "and a_crm_orders.summ-a_crm_orders.delivery_cost>=#{params[:ch1]}"
      @p_ch2 = params[:ch2].to_s==='' ? "" : "and a_crm_orders.summ-a_crm_orders.delivery_cost<=#{params[:ch2]}"
    end
  end
  
end
