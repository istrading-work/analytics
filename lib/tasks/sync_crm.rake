require "#{Rails.root}/lib/synccrm"

desc "Sync CRM"
task sync_crm: :environment  do
  begin
    puts Time.now
    s = SyncCrm.new('https://reprisa.retailcrm.ru', '70UNK4g5ysofzNtDg2kmUcOiHnuCXfo1')
    [["delivery-types",ACrmDeliveryType], ["status-groups",ACrmStatusGroup], ["statuses",ACrmStatus], ["shops",ACrmShop], ["users", ACrmUser]].each do |ref|
      print "\n"+ref[0]
      ASync.create(kind:ref[0])
      status = s.sync(ref[0])
      t = (ASync.where(kind: ref[0]).last(2).first.created_at.utc).strftime('%F %T')
      total_changed = ref[1].where("updated_at>= \'#{t}\'").count
      ASync.where(kind: ref).last.update_attributes!(status: status, total_changed: total_changed, done: true)
    end

    puts "\norders"
    ASync.create(kind:'orders')
    filter = ACrmShop.where(is_active: true).map {|v|  ['sites',v.code]}
    status = s.sync('orders', filter)
    t = (ASync.where(kind: 'orders').last(2).first.created_at.utc).strftime('%F %T')
    total_changed = ACrmOrder.where("updated_at>= \'#{t}\'").count
    ASync.where(kind: 'orders').last.update_attributes!(status: status, total_changed: total_changed, done: true)

    puts "\nhistory"
    h = ASync.where(kind:'history', done: true, status: true).order('id').last
    latest_date = h.nil? ? 0 : h.created_at
    if latest_date==0
      puts "error !!!"
      return
    end
    filter = {'startDate'=>latest_date}
    ASync.create(kind:'history')
    status = s.sync('history', filter)
    t = (ASync.where(kind: 'history').last(2).first.created_at.utc).strftime('%F %T')
    total_changed = ACrmHistory.where("updated_at>= \'#{t}\'").count
    ASync.where(kind: 'history').last.update_attributes!(status: status, total_changed: total_changed, done: true)
    
=begin
    orders = ACrmOrder.order('id desc')
    status = 'true'
    ASync.create(kind:'history', total_orders: orders.count)
    orders.each_with_index do |order,index|
      ASync.where(kind: 'history').last.update_attributes!(a_crm_order_id: order.id, order_index: index+1)
      h = ASync.where(kind:'history', done: true, status: true).order('id').last
      dt = h.nil? ? 0 : h.created_at
      if dt === 0
        h1 = ACrmHistory.where(a_crm_order_id:order.id).order('id').last
        dt1 = h1.nil? ? 0 : h1.dt
        if dt1 === 0 
          filter = {'orderId'=>order.id}
        else
          h2 = ACrmHistory.where(a_crm_order_id:order.id).order('last_updated_at desc').first
          dt2 = h2.last_updated_at
          latest_date = dt2.nil? ? dt1 : [dt1, dt2].max
          filter = {'orderId'=>order.id, 'startDate'=>latest_date}
        end
      else
        latest_date = dt
        filter = {'orderId'=>order.id, 'startDate'=>latest_date}      
      end
      print "\r#{((index+1)*100/ACrmOrder.all.size).round(0)}% #{index+1}/#{ACrmOrder.all.size} #{order.id}"
      status = status && s.sync('history', filter)
    end
    t = (ASync.where(kind: 'history').last(2).first.created_at.utc).strftime('%F %T')
    total_changed = ACrmHistory.where("updated_at>= \'#{t}\'").count
    ASync.where(kind: 'history').last.update_attributes!(status: status, total_changed: total_changed, done: true)
=end

    puts "\n", Time.now
    h = Time.now.hour
    if h>=21 || h<6
      sleep 3*60*60
    else
      sleep 10*60
    end
  end while true
end
  