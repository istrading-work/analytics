class BetaproService

  def export_to_betapro_by_status
    log = []
    File.open('log.txt', 'a') do |f|
      f.puts "", "Экспорт заказов", DateTime.now 
      retail = Retail.new
      orders = retail.orders([
        ['extendedStatus','ff-betapro'],
        ['sites', 'gelmifort'],
        ['sites', 'art-iphone'],
        ['sites', 'asd-ru'],
        ['sites', 'art-hs'],
        ['sites', 'art-bridzhy']
      ])
      if orders
        f.puts "Total: #{orders.count}"
        orders.each do |order|
          betapro = Betapro.new(retail, order['site'])
          result = betapro.p101(order)
          if result[:status]==0
            txt = "num=#{order["number"]} Ок!"
            f.puts txt
            log << txt
            retail.order_update_status(order['id'], order['site'], 'betapro-complete')
          else
            txt = "num=#{order["number"]} Ошибка: #{result[:error]}"
            f.puts txt
            log << txt
            retail.order_update_status(order['id'], order['site'], 'betapro-export-error')
          end
        end
      end
    end
    log
  end

  def export_to_betapro_by_id(order_id)
    File.open('log.txt', 'a') do |f|
      f.puts "", "Экспорт заказов", DateTime.now 
      retail = Retail.new
      orders = retail.orders([['ids',order_id]])
      if orders
        f.puts "Total: #{orders.count}"
        orders.each do |order|
          #if order['site']=='gelmifort'
            betapro = Betapro.new(retail, order['site'])
            result = betapro.p101(order)
            if result[:status]==0
              f.puts "num=#{order["number"]} Ок!"
              retail.order_update_status(order['id'], order['site'], 'betapro-complete')
            else
              f.puts "num=#{order["number"]} Ошибка: #{result[:error]}"
              retail.order_update_status(order['id'], order['site'], 'betapro-export-error')
            end
          #end
        end
      end
    end
  end

  def import_to_crm
    log = []
    File.open('log.txt', 'a') do |f|
      f.puts "", "Трэкинг", DateTime.now 
      retail = Retail.new
      orders = retail.orders([
        ['extendedStatus', 'betapro-group'],
        ['extendedStatus', 'obzvon-na-vykup-group'],
        ['sites', 'gelmifort'],
        ['sites', 'art-iphone'],
        ['sites', 'asd-ru'],
        ['sites', 'art-hs'],
        ['sites', 'art-bridzhy']
      ])
      if orders
        f.puts "Total: #{orders.count}"
        oa = []
        orders.each do |order|
          h = { "order_id": order['id'], "order_num": order['number'], "order_site": order['site'] }
          oa.push h
        end

        h = {}
        oa.each do |x|
          h[x[:order_site]] = [] if !h[x[:order_site]]
          h[x[:order_site]].push x
        end
        
        h.each_key do |site|
          betapro = Betapro.new(retail, site)
          result=betapro.p550(h[site], f)
          if result[:status]==0
            h[site].each do |x|
              retail.order_update_delivery_barcode(x[:order_id], site, result[:barcode][x[:order_num]])
              state_code = result[:data][x[:order_num]]
              #print x[:order_num], " ", result[:barcode][x[:order_num]]
              #puts
              if state_code.to_i > 0
                if retail.order_update_status(x[:order_id], site, "betapro-" + state_code)
                  f.print state_code, " "
                  f.puts x
                  log << "#{x[:order_num]} betapro-#{state_code}"
                else
                  log << "#{x[:order_num]} #{retail.upd_response}" if retail.upd_response != ""
                end
              else
                result2=betapro.p152(x[:order_id], f)
                if result2[:status]==-1
                  #puts "#{x[:order_id]}, #{result2}"
                  if retail.order_update_status(x[:order_id], site, "betapro-777")
                    log << "#{x[:order_num]} betapro-777"
                  end
                end
              end
            end
          else
            f.puts "Обратка Ошибка: #{result[:error]}"
          end
          
        end

      end
    end
    log
  end

end