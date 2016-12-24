require "#{Rails.root}/lib/retailcrm"

class Retail
  
  attr_reader :upd_response
 
  def initialize
    @client = Retailcrm.new('https://reprisa.retailcrm.ru', '70UNK4g5ysofzNtDg2kmUcOiHnuCXfo1')
  end
  
  def upd_response
    @upd_response
  end
  
  def orders(filter)
    orders = []
    totalCount = 0
    page = 1
    begin
      r = @client.orders(filter, 100, page)
      return false unless r.is_successfull? && r.response["pagination"]["totalCount"]>=1
      orders.push r.response["orders"]
      totalPageCount = r.response['pagination']['totalPageCount']
      totalCount = r.response['pagination']['totalCount']
      page = page + 1
    end while (page <= totalPageCount)
    orders.flatten!
  end
  
  def order_update_status(id, site, new_status)
    is_updated = false
    @upd_response = ""
    r = @client.orders_get(id, 'id', site)
    if r.is_successfull?
      order = r.response['order']
      cond = ((order['status'] != new_status) \
         && (!(order['status']=="uzhie-vykupili" && new_status=="betapro-3")) \
         && (!(order['status']=="otkaz-ot-vykupa" && new_status=="betapro-3")) \
         && (!(order['status']=="pieriezvonit-pozzhie" && new_status=="betapro-3")) \
         && (!(order['status']=="niedozvon-pri-obzvonie-na-vykup" && new_status=="betapro-3")) \
         && (!(order['status']=="uzhie-vykupili" && new_status == "betapro-5")) \
         && (!(order['status']=="otkaz-ot-vykupa" && new_status == "betapro-5")) \
         && (!(order['status']=="pieriezvonit-pozzhie" && new_status == "betapro-5")) \
         && (!(order['status']=="niedozvon-pri-obzvonie-na-vykup" && new_status == "betapro-5")) \
         && ((new_status=="betapro-777" && (order['status']=="betapro-999" || order['status']=="betapro-complete" || order['status']=="betapro-1" || order['status']=="betapro-2" || order['status']=="3" )) || new_status!="betapro-777"))
      if cond 
        ord = {'id'=>order['id'], 'status'=>new_status}
        r = @client.orders_edit(ord)
        if r.is_successfull?
          is_updated = true
        else
          print order['id'], " "
          puts r.response
          @upd_response = r.response
        end
      else
        #puts "#{id}, #{order['status']}, #{new_status}, #{order['site']}"
      end
    else
      puts r.response
    end
    is_updated
  end
  
  def order_update_delivery_barcode(id, site, new_barcode)
    is_updated = false
    r = @client.orders_get(id, 'id', site)
    
    if r.is_successfull?
      order = r.response['order']
      if (order['customFields']['track_pochta'] != new_barcode)
        puts "!!!", id, new_barcode, "!=", order['customFields']['track_pochta']
        ord={'id'=>order['id'], 'customFields'=>{'track_pochta'=>new_barcode}}
        @client.orders_edit(ord)
        is_updated = true
      end
    end
    is_updated
  end
  
  def sites
    @client.sites.response["sites"]
  end
  
end
