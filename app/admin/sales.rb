ActiveAdmin.register_page "Sales" do

  menu parent: "Reports", label: "Статистика продаж"

  content title: 'Статистика продаж' do
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

          select name:"shops", 'data-placeholder':"Магазины...", style:"width:350px;", multiple:true, class:"chosen-select" do
            ACrmShop.by_user(current_a_admin_user.id).each do |shop|
              option value:"'#{shop.code}'", selected:true do
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

    panel "График распределения кол-во заказов = func (чек)" do
      div id: 'graph_distribution'
    end

		panel "Свод по магазинам" do
			table id:'output2', class:"compact"
		end
    
    panel "Детали" do
      table id:'output' , class:"compact"
    end
    
  end

  page_action :ex_day do 
    set_filter
    render json: ACrmOrder.sales_report_day(@p_date1, @p_date2, @p_shops, @p_ch1, @p_ch2)
  end 

  page_action :ex_week do 
    set_filter
    render json: ACrmOrder.sales_report_week(@p_date1, @p_date2, @p_shops, @p_ch1, @p_ch2)
  end

  page_action :ex_month do 
    set_filter
    render json: ACrmOrder.sales_report_month(@p_date1, @p_date2, @p_shops, @p_ch1, @p_ch2)
  end

  page_action :ex_total do 
    set_filter
    render json: ACrmOrder.sales_report_total(@p_date1, @p_date2, @p_shops, @p_ch1, @p_ch2)
  end 

  page_action :ex_distribution do 
    set_filter
    render json: ACrmOrder.distribution(@p_date1, @p_date2, @p_managers, @p_shops, @p_ch1, @p_ch2)
  end 
  
  controller do
    def set_filter
      @p_date1 = params[:date1].to_s==='' ? "" : "and a_crm_orders.dt>='#{Time.parse(params[:date1]).beginning_of_day.utc}'"
      @p_date2 = params[:date2].to_s==='' ? "" : "and a_crm_orders.dt<='#{Time.parse(params[:date2]).end_of_day.utc}'"
      @p_shops = params[:shops]==='null' ? "" : "and a_crm_orders.a_crm_shop_id in (#{params[:shops]})"
      @p_ch1 = params[:ch1].to_s==='' ? "" : "and a_crm_orders.summ-a_crm_orders.delivery_cost>=#{params[:ch1]}"
      @p_ch2 = params[:ch2].to_s==='' ? "" : "and a_crm_orders.summ-a_crm_orders.delivery_cost<=#{params[:ch2]}"
    end
  end
  
end
