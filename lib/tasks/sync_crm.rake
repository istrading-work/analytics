require "#{Rails.root}/lib/synccrm"

desc "Sync CRM"
task sync_crm: :environment  do
  puts Time.now
  s = SyncCrm.new('https://reprisa.retailcrm.ru', '70UNK4g5ysofzNtDg2kmUcOiHnuCXfo1')
  print "delivery-types"; s.sync('delivery-types')
  print "\nstatus-groups"; s.sync('status-groups')
  print "\nstatuses"; s.sync('statuses')
  print "\nshops"; s.sync('shops')
  print "\nusers"; s.sync('users')
  filter = ACrmShop.where(is_active: true).map {|v|  ['sites',v.code]}
  puts "\norders"; s.sync('orders', filter)

  puts "\nhistory" 
  ACrmOrder.order('id desc').each_with_index do |order,index|
    h1 = ACrmHistory.where(a_crm_order_id:order.id).order('id desc').first
    dt1 = h1.nil? ? 0 : h1.dt
    if dt1 === 0 
      filter = {'orderId'=>order.id}
    else
      h2 = ACrmHistory.where(a_crm_order_id:order.id).order('last_updated_at desc').first
      dt2 = h2.last_updated_at
      latest_date = dt2.nil? ? dt1 : [dt1, dt2].max
      filter = {'orderId'=>order.id, 'startDate'=>latest_date}
    end
    print "\r#{((index+1)*100/ACrmOrder.all.size).round(0)}% #{index+1}/#{ACrmOrder.all.size} #{order.id}"
    s.sync('history', filter)
  end
  puts "\n", Time.now 
end
