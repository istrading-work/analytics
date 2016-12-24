require 'xmlsimple'

class Betapro

  def initialize(retail, site)
    @url = 'http://api.betapro.ru:8080/bp/hs/wsrv'
    if site=='gelmifort'
      @partner_id = "786"
      @password = "erqhgb"
      @delivery_id = "S-shipping"
    elsif site=='art-iphone' || site=='asd-ru' || site=='art-hs' || site=='art-bridzhy'
      @partner_id = "839"
      @password = "34rdf56"
      @delivery_id = "007"
    else
      @partner_id = ""
      @password = ""
      @delivery_id = ""      
    end
    @retail = retail
  end

  def p154(order_id, f_log)
    hash = {
      "request": [{
        "request_type":"154",  
        "partner_id":@partner_id,
        "password":@password,
        "order": [{
          "order_id": order_id
        }] 
      }]
    } 
    request_xml = ::XmlSimple.xml_out(hash, {"RootName":nil})
      
    response = {}

    begin
      response_raw = post_xml(@url, request_xml)
      response = ::XmlSimple.xml_in(response_raw)
    rescue
      f_log.puts response_raw
      puts "retry"
      sleep 1*60
      retry
    end
    
    if response["state"].to_i==0
      if response["parcel"]
        st = response["parcel"][0]["parcel_state"]
        {"status":0, data:st.to_i}
      else
        {"status":0, data:0}
      end
    else
      e = ""
      response["error"].each do |error|
        e += error["msg"]+"\n"
      end
      {"status":-1, "error": e}
    end
  end

  def p152(order_id, f_log)
    hash = {
      "request": [{
        "request_type":"152",  
        "partner_id":@partner_id,
        "password":@password,
        "order_id": order_id,
        "active_only": "0"
      }]
    } 
    request_xml = ::XmlSimple.xml_out(hash, {"RootName":nil})
      
    response = {}

    begin
      response_raw = post_xml(@url, request_xml)
      response = ::XmlSimple.xml_in(response_raw)
    rescue
      f_log.puts response_raw
      puts "retry"
      sleep 1*60
      retry
    end
    
    if response["state"].to_i==0
      unless response["order_row"]
        {"status":-1}
      else
        {"status":0}      
      end
    else
      e = ""
      response["error"].each do |error|
        e += error["msg"]+"\n"
      end
      {"status":-1, "error": e}
    end
  end
  
  def p550(order_h, f_log)
    oa = []
    order_h.each do |oi|
      h = {"order_id": oi[:order_num]}
      oa.push h
    end
    hash = {
      "request": [{
        "request_type":"550",  
        "partner_id":@partner_id,
        "password":@password,
        "parcel": oa
      }]
    } 
    request_xml = ::XmlSimple.xml_out(hash, {"RootName":nil})
    response = {}
    begin
      #puts request_xml
      response_raw = post_xml(@url, request_xml)
      #puts response_raw
      response = ::XmlSimple.xml_in(response_raw)
    rescue
      f_log.puts response_raw
      puts "retry"
      sleep 1*60
      retry
    end
    
    if response["state"].to_i==0
      r = {}
      b = {}
      response["parcel"].each do |p|
        r[p["order_id"]] = p["state_code"]
        b[p["order_id"]] = p["barcode"]
        sost = p154(p["order_id"], f_log)[:data]
        if sost>0 && p["state_code"].to_i==0
          result2=p152(p["order_id"], f_log)
          if result2[:status]==-1
            r[p["order_id"]] = "777"
          else
            r[p["order_id"]] = "999"
          end
        elsif sost==2
          r[p["order_id"]] = "888"
        end
      end
      {"status":0, data:r, barcode:b}
    else
      e = ""
      response["error"].each do |error|
        e += error["msg"]+"\n"
      end
      {"status":-1, "error": e}
    end
  end
  
  def p161(goods)
    hash = {
      "request": [{
        "request_type":"161",  
        "partner_id":@partner_id,
        "password":@password,
        "good": goods
      }]
    } 
    request_xml = ::XmlSimple.xml_out(hash, {"RootName":nil})
    response = ::XmlSimple.xml_in(post_xml(@url, request_xml))
    if response["state"].to_i==0
      {"status":0}
    else
      e = ""
      response["error"].each do |error|
        e += error["msg"]+"\n"
      end
      {"status":-1, "error": e}
    end
  end
  
  def p101(order)
    sites = @retail.sites
    number = order["number"]
    clnt_name = ""
    lastName = order.has_key?("lastName") ? order["lastName"] : "" 
    firstName = order.has_key?("firstName") ? " " + order["firstName"] : "" 
    patronymic = order.has_key?("patronymic") ? " " + order["patronymic"] : "" 
    
    clnt_name = "#{lastName}#{firstName}#{patronymic}".strip
    
    clnt_phone = order["phone"]
    
    if order.has_key?("delivery") && order["delivery"].has_key?("address")
      if order["delivery"]["address"].has_key?("index")
        zip = order["delivery"]["address"]["index"]
      else
        return {"status":-7, "error": "Не указан индекс"}
      end
      if order["delivery"]["address"].has_key?("region")
        region =  order["delivery"]["address"]["region"]
      else
        return {"status":-2, "error": "Не указан регион"}
      end
      if order["delivery"]["address"].has_key?("city")      
        city = order["delivery"]["address"]["city"]
      else
        return {"status":-3, "error": "Не указан город"}
      end
      
      street = order["delivery"]["address"].has_key?("street") ? order["delivery"]["address"]["street"] : ""
      
      if order["delivery"]["address"].has_key?("building")
        r_building = "д. " + order["delivery"]["address"]["building"]  #дом
      else
        return {"status":-4, "error": "Не указан дом"}
      end
      
      r_house = order["delivery"]["address"].has_key?("house") ? " корп. " + order["delivery"]["address"]["house"] : ""       #корпус
      r_flat =  order["delivery"]["address"].has_key?("flat") ? " кв. " + order["delivery"]["address"]["flat"] : ""           #квартира
      house = "#{r_building}#{r_house}#{r_flat}"      
      f103addr = "#{order['delivery']['address']['region']}, г. #{order["delivery"]["address"]["city"]}"
      post_addr = [f103addr, order["delivery"]["address"]["text"]].join(" ")

      delivery_memo = ""
      delivery_memo += 'доставка ' + order["delivery"]["date"] if order["delivery"].has_key?("date") && order["delivery"]["date"].is_a?(String)
      if order["delivery"].has_key?("time")
        delivery_memo += " c #{order['delivery']['time']['from']}" if order["delivery"]["time"].has_key?("from")
        delivery_memo += " до #{order['delivery']['time']['to']}" if order["delivery"]["time"].has_key?("to")
      end
      #puts delivery_memo
      
      if order["delivery"].has_key?("code")
        dc = order["delivery"]["code"]
        if dc == "betapro" && order["delivery"].has_key?("service")
          if order["delivery"]["service"].has_key?("code")
            dc2 = order["delivery"]["service"]["code"]
            if dc2 == 'beta-dpd'
              delivery_type = 1
            elsif dc2 == 'beta-maxipost'
              delivery_type = 8
            elsif dc2 == 'beta-cdek'
              delivery_type = 3              
            end
          end
        elsif dc == "russian-post"
          delivery_type = 1
        elsif dc == "maxipost"
          delivery_type = 8
        elsif dc == "cdek"
          delivery_type = 3
        else
          return {"status":-6, "error": "Неизвестный тип доставки"}
        end
      else
        return {"status":-5, "error": "Не указан тип доставки"}      
      end

    else
      return {"status":-1, "error": "Не указан адрес"}
    end

    items = order["items"]
    rows = []
    goods = []
    
    idx = 1
    items.each do |item|
      offer = item["offer"]
=begin     
      good = {
        "good_id": offer["externalId"],
        "good_name": offer["name"]
      }
      goods.push(good)
=end  
      quantity = item["quantity"].to_i
      
      quantity.times do 
        row = {
          "order_id":number,
          "good_id": offer["externalId"],
          "ordrow_id": "#{number}/#{offer["externalId"]}/#{idx}",
          "price": item["initialPrice"],
          "clnt_price": item["initialPrice"]
        }
        rows.push(row)
        idx = idx + 1
      end
    end

    # Доставка
    if order["delivery"].has_key?("cost") && order["delivery"]["cost"]>0
=begin
    good = {
        "good_id": "delivery_cost",
        "good_name": "Доставка"
      }
      goods.push(good)
=end            
      row = {
        "order_id":number,
        "good_id": @delivery_id,
        "ordrow_id": "#{number}/#{@delivery_id}/#{rows.count+1}",
        "price": 0,
        "clnt_price": order["delivery"]["cost"]
      }
      
      rows.push(row)
    else
      return {"status":-8, "error": "Не указана стоимость доставки"}
    end
      
    #p161(goods)
    
    hash = {
      "request": [{
        "request_type":"101",  
        "partner_id":@partner_id,
        "password":@password,
        "doc":[{
          "doc_type":"5", 
          "zdoc_id":"T"+number,
          "order":[{
            "order_id":number,
            "delivery_type":delivery_type,
            "dev1mail_type":"16",
            "doc_txt":delivery_memo,
            "delivery_memo":delivery_memo,
            "zip":zip,
            "clnt_name":clnt_name,
            "clnt_phone":clnt_phone,
            "struct_addr": [{
              "region":region,
              "city":city,
              "street":street,
              "house":house
            }]
          }],
          "order_row": rows
        }]
      }]
    }
    
    request_xml = ::XmlSimple.xml_out(hash,{"RootName":nil})
    #puts hash
    #puts request_xml
    #{"status":0}

    response = ::XmlSimple.xml_in(post_xml(@url, request_xml))
    puts response
    if response["state"].to_i==0
      {"status":0}
    else
      e = ""
      response["error"].each do |error|
        e += error["code"] + " " + error["msg"]+"\n"
      end
      {"status":-1, "error": e}
    end
    
  end
  
  private
    def post_xml url_string, xml_string
      uri = URI.parse url_string
      request = Net::HTTP::Post.new uri.path
      request.body = xml_string
      request.content_type = 'text/xml'
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
      response.body
    end

end