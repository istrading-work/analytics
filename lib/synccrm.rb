require "#{Rails.root}/lib/retailcrm"
class SyncCrm
  
  def initialize(url,key)
    @client = Retailcrm.new(url, key)
  end

  def sync(api_method, filter = nil )
    @api_method = api_method
    data = {
    'delivery-types'=>['r',:delivery_types,'ACrmDeliveryType','deliveryTypes',{'code'=>'code','name'=>'name','is_active'=>'active'}],
    'status-groups' =>['r',:status_groups, 'ACrmStatusGroup', 'statusGroups', {'code'=>'code','name'=>'name','is_active'=>'active'}],
    'statuses'      =>['r',:statuses,      'ACrmStatus',      'statuses',     {'code'=>'code','name'=>'name','crm_group_id'=>'group','is_active'=>'active'}],
    'shops'         =>['r',:sites,         'ACrmShop',        'sites',        {'code'=>'code','name'=>'name','is_active'=>nil}],
    
    'users'         => ['c',:users,'ACrmUser','users',
                        {'id'=>'id',
                         'last_name'=>'lastName',
                         'first_name'=>'firstName',
                         'email'=>'email',
                         'is_manager'=>'isManager',
                         'is_active'=>'active'
                       }],
                       
    'orders'        => ['c',:orders,'ACrmOrder','orders',
                        {'id'=>'id',
                         'num'=>'number',
                         'dt'=>'createdAt',
                         'summ'=>'totalSumm',
                         'a_crm_status_id'=>'status', 
                         'a_crm_shop_id'=>'site',
                         'a_crm_user_id'=>'managerId',
                         'dt_status_updated'=>'statusUpdatedAt',
                         'a_crm_delivery_type_id'=>'delivery|code',
                         'delivery_cost'=>'delivery|cost',
                         'delivery_net_cost'=>'delivery|netCost' 
                        }],
                        
    'history'       => ['c',:orders_history, 'ACrmHistory', 'history',
                        {'id'=>'id',
                         'dt'=>'createdAt',
                         'a_crm_order_id'=>'order|id',
                         'a_crm_status_id'=>'newValue|code'
                        }]
    }

    return false unless data.has_key?(api_method)
    v = data[api_method]
    what, @retailcrm_api_method, @model, @response_key, @selected_params = v[0], v[1], eval(v[2]), v[3], v[4]

    if    (what == 'r') then sync_reference
    elsif (what == 'c') then sync_collection(filter)
    end
    true
  end

  private
  
    def sync_reference
      response = @client.method(@retailcrm_api_method).call
      return false unless response.is_successfull? && !response.response.empty?
      get_items(response)

      response_has_only_active_items = @items.first['is_active'].nil?
      @model.update_all is_active: false if response_has_only_active_items

      @items.each do |item|
        item['is_active'] = response_has_only_active_items ? true : item['is_active']
        @model.find_or_initialize_by(code: item['code']).update_attributes!(item)
      end

    end

    def sync_collection(filter = nil, limit = 100, page = 1)
      begin
        response = @client.method(@retailcrm_api_method).call(filter, limit, page)
        return false unless response.is_successfull? && !response.response.empty?
        get_items(response)
       
        @items.each do |item|
          if @api_method==='history'
            unless @model.exists?(id: item['id'])
              unless @model.exists?(a_crm_order_id: item['a_crm_order_id'], a_crm_status_id: item['a_crm_status_id'])
                @model.find_or_initialize_by(id: item['id']).update_attributes!(item)
              else 
                #open('myfile.out', 'a') do |f|
                #  f.puts "#{item['a_crm_order_id']} - #{item['a_crm_status_id']}"
                #end
                params = {}
                params['last_updated_at']=item['dt']
                @model.find_by(a_crm_order_id: item['a_crm_order_id'], a_crm_status_id: item['a_crm_status_id']).update_attributes!(params)
              end
            end
          else
            @model.find_or_initialize_by(id: item['id']).update_attributes!(item)
          end
        end

        totalPageCount = response.response['pagination']['totalPageCount']
        if @api_method != 'history'
          print "\rPage ",page, "/", totalPageCount," ", response.response['pagination']['totalCount']
        end
        page = page + 1
      end while (page <= totalPageCount)
    end

    def get_items(response)
      items_raw = response.response[@response_key]
      iterator = items_raw.is_a?(Hash) ? :each_value : :each
      @items = []
      items_raw.method(iterator).call do |item|
        if @api_method==='history'
          next if item['field']!='status'
        end
        params = {}
        @selected_params.each do |k,v|
          vs = v.nil? ? []: v.split('|')
          if    vs.size==1 then params[k] = item.has_key?(v) ? item[v] : nil
          elsif vs.size==2 then params[k] = (item.has_key?(vs[0]) && item[vs[0]] && item[vs[0]].has_key?(vs[1])) ? item[vs[0]][vs[1]] : nil
          else  params[k] = nil
          end
        end
        @items.push(params)
      end
    end
end
