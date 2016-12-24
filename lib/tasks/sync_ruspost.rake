require 'net/http'

class RussianPost

  def initialize
    @lists = []
    i, list = 0, {}
    puts ACrmOrder.in_post.russian_post.with_track.count
    ACrmOrder.in_post.russian_post.with_track.each do |order|
      list[order.track_pochta] = order.id
      i += 1
      if i>19
        @lists << list
        i, list = 0, {}
      end
    end
    @lists << list unless list.empty?
  end

  def save_tracks
    @lists.each do |list|
      barcodeList = ""
      list.each_key do |barcode|
        barcodeList += "&barcodeList=#{barcode}"
      end
      r = rand(1481111111111..1489999999999)
      
      uri_string = "https://www.pochta.ru/tracking?p_p_id=trackingPortlet_WAR_portalportlet&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=getList&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=2#{barcodeList}&postmanAllowed=true&_=#{r}"

      res = process_uri(uri_string)
      if res
       st = save_response(res.body)
       return st if st<0
      end
    end
    0
  end
  
  private
    def process_uri(uri_string)
      uri = URI.parse(uri_string)
      
      http = nil
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri, {'Accept-Language' => 'ru'})
      
      #proxy_addr = '82.146.37.33'
      #proxy_port = 8888
      #proxy = Net::HTTP::Proxy(proxy_addr, proxy_port)
      begin
=begin
        res = proxy.start(uri.host,uri.port) do |http|
          http.request(request)
        end
=end 
        res = http.request(request)
        puts res.header.inspect
        if res.is_a?(Net::HTTPOK)
          res
        else
          nil
        end
      rescue Exception => e 
        puts e
        sleep 20*60
        retry
      end    
    end
    
    def save_response(json_string)
      res = JSON.parse(json_string)
      if res.has_key?('error')
        puts res['error']['description']
        return -2
      end
      if res['list'].empty?
        puts 'Забанили'
        return -1
      end
      res['list'].each do |data|
        if data
          address = data['officeSummary']['addressSource'] if data['officeSummary']
          if data['trackingItem']
            com_status = data['trackingItem']['commonStatus']
            barcode = data['trackingItem']['barcode']
            params = {post_status: com_status, post_address: address}
            order_id = nil
            @lists.each do |list|
              order_id = list[barcode]
              break if order_id
            end
            ACrmOrder.find_by(id: order_id).update_attributes!(params)
            #puts "#{com_status} #{address}"
            history = data['trackingItem']['trackingHistoryItemList']
            history.each do |h|
              dt = h['date'].to_time
              desc = h['description']
              hum_status = h['humanStatus']
              op_type = h['operationType']
              op_attr = h['operationAttr']
              index = h['index']
              item = {dt: dt, status: hum_status, pd_index: index, pd_desc: desc, op_type: op_type, op_attr: op_attr, a_crm_order_id: order_id}
              APostHistory.create(item) unless APostHistory.exists?(a_crm_order_id: order_id, dt: dt, op_type: op_type, op_attr: op_attr) 
              #puts "#{order_id} #{dt.strftime('%d-%m-%Y %T')} #{index} #{desc} #{hum_status}"
            end
          end
        end
      end
      0
    end
end

desc "Sync Russian Post"
task sync_ruspost: :environment  do
  begin
    begin
      puts "\n", Time.now
      st = RussianPost.new.save_tracks
      puts '---'
      if st==-1
        sleep 20*60
      else
        sleep 1*60*60
      end
    end while true
  end
end
