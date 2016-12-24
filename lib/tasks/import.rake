require 'net/http'
require "#{Rails.root}/lib/retailcrm"

def process_uri(uri_string)
  uri = URI.parse(uri_string)
  http = nil
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri, {'Accept-Language' => 'ru'})
  res = http.request(request)
  puts res.header.inspect
  if res.is_a?(Net::HTTPOK)
    res
  else
    nil
  end
end


class Retail
  
  def initialize
    @client = Retailcrm.new('https://reprisa.retailcrm.ru', '70UNK4g5ysofzNtDg2kmUcOiHnuCXfo1')
  end
  
  def order_update_rd_id(id, site, rd_id)
    r = @client.orders_get(id, 'id', site)
    
    if r.is_successfull?
      order = r.response['order']
      puts order
      if (order['customFields']['rd_id'] != rd_id)
        puts "!!!", rd_id, "!=", order['customFields']['rd_id']
        ord={'id'=>id, 'customFields'=>{'rd_id'=>rd_id}}
        puts @client.orders_edit(ord).response
      end
    end
  end
  
end
  
desc "Import RD"
task import: :environment  do
  begin
    counter = 1
    file = File.new("/var/www/artelion/data/www/istrading.ru/workspace/analytics/lib/tasks/2.csv", "r")
    o_rd = {}
    while (line = file.gets)
      ln = line.split(';')
      last_name = UnicodeUtils.downcase(ln[2])
      city = UnicodeUtils.downcase(ln[7])
      sum = ln[5].to_i
      rd_id = ln[0]
      el = {sum: sum, rd_id:rd_id, city:city} 
      o_rd[last_name]=el
      #puts "#{counter}: #{last_name} #{sum}"
      counter = counter + 1
    end
    file.close
    #puts o_rd

    uri_string = "https://reprisa.retailcrm.ru/api/v4/orders?apiKey=70UNK4g5ysofzNtDg2kmUcOiHnuCXfo1&filter[extendedStatus][]=rd-dostavka&limit=100"
    res = process_uri(uri_string)
    t = []
    if res
      t = JSON.parse(res.body)['orders']
    end
    o_crm = []
    t.each do |o|
      k=UnicodeUtils.downcase("#{o['firstName']} #{o['lastName']}")
      crm_id = o['id']
      sum = o['totalSumm']
      city = UnicodeUtils.downcase(o['delivery']['address']['city'])
      o_crm << {name: k, crm_id: crm_id, sum: sum, city: city}
    end
    #puts o_crm
    
    res = {}
    o_rd.each do |k,v|
      find = false
      o_crm.each do |c|
        if c[:name].include?(k) && c[:sum].to_i==v[:sum].to_i
          #puts "#{k} #{v[:city]} #{v[:sum]} #{v[:rd_id]}"
          #puts "#{c[:name]} #{c[:city]} #{c[:sum]} #{c[:crm_id]}"
          #puts
          res[c[:crm_id]] = v[:rd_id]
          find = true
        end
      end
      #puts k unless find
    end
    
    puts res.count
    
    retail = Retail.new
    res.each do |k,v| 
      retail.order_update_rd_id(k,'reddiamond',v)
      puts "#{k} - #{v}"
    end    
  end
end