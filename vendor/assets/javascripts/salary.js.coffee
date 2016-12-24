gd = []
ttt1  = []
ttt11  = []
ttt2 = []
ttt22 = []
hidden_cols_g = []#_.range(2, 25);

Date::addDays = (d) ->
  @setDate @getDate() + d
  this
  
calc = (item, stat, stat_prev) ->
  bch = 0
  bch_prev = 0
  if item.buy_count != 0
    bch = item.buy_sum / item.buy_count
  ap = 100*item.approve_count/item.total_count
  a2p = 100*item.approve2_count/item.total_count
  tb = item.po_count + item.buy_count + item.ret_count
  b2p = 0
  if tb>0
    b2p = 100*item.buy_count/tb
  aa = a2p - ap
  a_ave = 0
  a2_ave = 0
  if stat[item.shop]
    a_ave = 100 * stat[item.shop][0] / stat[item.shop][2]
    a2_ave = 100 * stat[item.shop][1] / stat[item.shop][2]
  aa_ave = a2_ave - a_ave
  b_prev = 0
  b_ave_prev = 0
  if stat_prev[item.shop]
    b_ave_prev = 100 * stat_prev[item.shop][0] / stat_prev[item.shop][1]
    df = _.where(stat_prev[item.shop][2], manager:item.manager)
    if df.length>0
      b_prev = 100 * df[0]['buy_count'] / df[0]['approve_count']
      bch_prev = df[0]['buy_sum'] / df[0]['buy_count']
      
  bp = 0
  rp = 0
  brp = 0
  if item.approve_count != 0
    bp = 100*item.buy_count/item.approve_count
    rp = 100*item.ret_count/item.approve_count
    brp = 100*(item.buy_count+item.ret_count)/item.approve_count

# bch        - а) Средний чек по выкупу менеджера
# a_ave      - б) Средний апрув за период по всем менеджерам
# aa_ave     - в) Средняя разница между апрувом+ и апрувом по всем менеджерам
# aa         - г) Разница между апрувом+ и апрувом по вычисляемому менеджеру
# b_ave_prev - д) Средний выкуп по всем менеджерам за период минус месяц от считаемого 
# b_prev     - е) Выкуп по конкретному менеджеру  за период минус месяц от считаемого
 
  k = 1
  z_max = 200
  
  if item.shop == '№2 Бриджи HS (свой офер)' || item.shop == '№8 Бриджи HS'
    k = 1.5
  else if item.shop == '№9 Пояс Hot Shaper'
    k = 1.3
  else if item.shop == '№3 Золотые цепочки'
    k = 1.2
  else if item.shop == 'Золотые цепочки (женские)'
    k = 1
  else if item.shop == '№5 Red Diamond'
    k = 1.45
  else if item.shop == 'Gelmifort'
    k = 1.4
  else if item.shop == '№6 Айфоны'
    k = 0.25
    z_max = 100
  else if item.shop == '№7 Айфоны 7'
    k = 0.2
    z_max = 100  
  else if item.shop == '№4 Бриджи HS Казахстан'
    k = 0.25
    z_max = 120
  else if item.shop == '№1 Мон. чай - от курения'
    k = 1.55
  
  k = k / 100
  
  ka  = 0
  ka2 = 0
  kb  = 1
  
  if a_ave
    ka = ap/a_ave
 
  if a2_ave
    ka2 = a2p/a2_ave
  
  if b_ave_prev && b_prev
    kb = b_prev/b_ave_prev

  bc = item.ch
  if b_prev>0
    bc = bch_prev
  else if bch>0
    bc = bch
    
  km = ka * ka2 * kb

  km_max = 1 + item.approve_count*0.1
  if km>km_max
    km = km_max 
    
  z = 50+k*(item.ch+bc)/2 * km

  if z>z_max
    z = z_max

  z_total = z*item.approve_count     
  _.extend(item, { bch:Math.round(bch), ap: parseFloat(ap.toFixed(2)), a2p: parseFloat(a2p.toFixed(2)), bp: parseFloat(bp.toFixed(2)), b2p: parseFloat(b2p.toFixed(2)), rp:Math.round(rp), brp:Math.round(brp), z: Math.round(z), z_total: Math.round(z_total), km: parseFloat(km.toFixed(2)), ka: ka.toFixed(2), ka2: ka2.toFixed(2), kb: kb.toFixed(2) })
  return
  
calc_t = (data, group, v) ->
  sum = {}
  ['z_total',  'total_count', 'approve_count', 'approve2_count', 'buy_count', 'ret_count', 'hold_count', 'cancel_count', 'approve_sum', 'buy_sum','po_count','pt_count','accept_count'].forEach (item) ->
    sum[item] = _.reduce(_.pluck(data, item), ((memo, s) ->
      memo + s
    ), 0)
    return
    
  s = 0

  data.forEach (item, i) ->
    s = s + item['total_count'] * item['km'] * item['z']
    return
  sum['km'] = s
  
  #non_zero_km = _.filter(data, (d) ->
  #  d['km'] > 0
  #)
  
  tb = sum['po_count'] + sum['buy_count'] + sum['ret_count']
  sum['b2p'] = 0
  if tb>0
    sum['b2p'] = (100*sum['buy_count']/tb).toFixed(2)
    
  if sum['total_count']>0
    sum['km'] = (sum['km']/sum['total_count']).toFixed(0)
  else
    sum['km'] = 0
  
  sum['ap'] = parseFloat((100 * sum['approve_count'] / sum['total_count']).toFixed(2))
  sum['a2p'] = parseFloat((100 * sum['approve2_count'] / sum['total_count']).toFixed(2))
  sum['ch'] = 0
  sum['bch'] = 0
  sum['bp'] = 0
  sum['rp'] = 0
  sum['brp'] = 0
  sum['z'] = 0
  if sum['approve_count'] != 0
    sum['ch'] = Math.round(sum['approve_sum'] / sum['approve_count'])
    sum['bp'] = parseFloat((100 * sum['buy_count'] / sum['approve_count']).toFixed(2))
    sum['rp'] = Math.round(100 * sum['ret_count'] / sum['approve_count'])
    sum['brp'] = Math.round(100 * (sum['buy_count'] + sum['ret_count']) / sum['approve_count'])  
    sum['z'] = Math.round(sum['z_total'] / sum['approve_count'])
  if sum['buy_count'] != 0  
    sum['bch'] = Math.round(sum['buy_sum'] / sum['buy_count'])
  gs = '<td>'
  if v==1 then (gs='<td colspan="2">')
  it_str = '<tr class="group">'+ gs + group + '</td><td>' + sum['total_count'] + '</td><td>' + sum['approve_count'] + '</td><td>' + sum['approve2_count'] + '</td><td>' + sum['buy_count'] + '</td><td>' + sum['po_count'] + '</td><td>' + sum['ret_count'] + '</td><td>' + sum['cancel_count'] + '</td><td>' + sum['pt_count'] + '</td><td>' + sum['accept_count'] + '</td><td>' + sum['hold_count'] + '</td><td>' + sum['ch'] + '</td><td>' + sum['bch'] + '</td><td>' + sum['ap'] + '</td><td>' + sum['a2p'] + '</td><td>' + sum['bp'] + '</td><td>' + sum['b2p'] + '</td><td>' + sum['rp'] + '</td><td>' + sum['brp'] + '</td><td>' + sum['z'] + '</td><td>' + sum['z_total']
  if $('#manager_name').text() == ''
    it_str = it_str + '</td><td colspan="4">' + sum['km'] + '</td></tr>'
  else
    it_str = it_str + '</td></tr>'
  return it_str

columns = [
  { title: 'Дата' }
  { title: 'Менеджер' }
  { title: 'Магазин' }
  { title: 'Всего' }
  { title: 'Апрув' }
  { title: 'Апрув&nbsp;+' }
  { title: 'Выкуп' }
  { title: 'В ПО' }
  { title: 'Возврат' }
  { title: 'Отмена' }
  { title: 'Путь' }
  { title: 'Принят' }
  { title: 'Холд' }
  { title: 'Ср.чек' }
  { title: 'Ср.чек выкуп' }
  { title: 'Апрув(%)' }
  { title: 'Апрув&nbsp;+(%)' }
  { title: 'Выкуп(%)' }
  { title: 'Выкуп&nbsp;+(%)' }
  { title: 'Возврат(%)' }
  { title: 'Выполнен(%)' }
  { title: 'Опл/заказ' }
  { title: 'Оплата' }
  { title: 'km' }
  { title: 'ka' }
  { title: 'ka2' }
  { title: 'kb' }
]

render_tbl = (data, t, it, v) ->
  m = $('#manager_name').text()
  hidden_cols = [it.group_col]
  hidden_cols = _.union(hidden_cols, hidden_cols_g)
  if m != ''
    dd=[]
    if it.gr == 'manager' || it.gr == 'shop'
      dd = _.partition(data, (item) ->
        item[0] == m
      )
      hidden_cols.push(22,23,24,25)
    else
      dd = _.partition(data, (item) ->
        item[1] == m
      )  
      hidden_cols.push(23,24,25,26)
    data=dd[0]
  $(it.el).DataTable
    destroy: true
    data: data
    displayLength: 100
    "columnDefs": [
      { "visible": false, "targets": hidden_cols } 
    ],
    columns: it.columns
    order: [[ it.group_col, "asc" ], [ 18, "desc" ]]
    drawCallback: (settings) ->
      api = @api()
      rows = api.rows().nodes()
      if m == ''
        $(rows).eq(0).before calc_t(t, 'Итого', v)
      last = null
      api.column(it.group_col).data().each (group, i) ->
        if last != group
          tt = []
          if it.gr == 'manager'
            tt = _.where(t, { manager : group })
          else if it.gr == 'shop'
            tt = _.where(t, { shop : group })
          else
            tt = _.where(t, { dt1 : group })
          $(rows).eq(i).before calc_t(tt, group, v) 
          last = group
      return
  return

render_gr = ->
  $('#graph').html('')
  ms = $('select[name=ms]').val()
  ss = $('select[name=ss]').val()
  p = $('select[name=p]').val()
  if ms && p && ss
    d1 = _.map _.where(gd, shop:ss), (item) ->
      _.pick(item, 'dt1','manager', p)    
    d2 = _.groupBy(d1, 'dt1');
    d = []
    Object.keys(d2).forEach (key, index) ->
      d3 = _.object(_.pluck(d2[key],'manager'), _.pluck(d2[key], p))
      sum = 0
      k = 0
      Object.keys(d3).forEach (key, index) ->
        sum += d3[key]
        k++
      av = 0
      if k>0
        av = Math.round(sum / k)
      _.extend(d3, {dt: key, "Среднее": av})
      d.push(d3)
    ms.push "Среднее"
    Morris.Line
      element: graph
      data: d
      xkey: 'dt'
      ykeys: ms
      labels: ms
      lineWidth: 2
      parseTime: false
      xLabelAngle:90
  return

render_gr_distribution = (data) ->
  $('#graph_distribution').html('')
  Morris.Line
    element: graph_distribution
    data: data
    xkey: 'ch'
    ykeys: ['cnt']
    labels: ['Кол-во']
    lineWidth: 2
    parseTime: false
  return

render_col = ->
  columns_ = _.rest(columns)
  [{el: '#output1', group_col: 0, columns: columns_, gr: 'manager'}, {el: '#output2', group_col: 1, columns: columns_, gr: 'shop'}].forEach (it) ->
    render_tbl(ttt1, ttt11, it, 0)
  render_tbl(ttt2, ttt22, {el: '#output', group_col: 0, columns: columns, gr: 'date'}, 1)
  return
  
render_all = ->
  url_p = "?date1="+$('input[name=date1]').val()+
          "&date2="+$('input[name=date2]').val()+
          "&managers="+$('select[name=managers]').val()+
          "&shops="+$('select[name=shops]').val() +
          "&ch1="+$('input[name=ch1]').val() +
          "&ch2="+$('input[name=ch2]').val()
          
  $.ajax(url: "salary/ex_total" + url_p).done (data) ->
    stat = {}
    shops = _.uniq(_.pluck(data, 'shop'))
    shops.forEach (shop) ->
      sum = {}
      ['approve_count', 'approve2_count', 'total_count'].forEach (item) ->
        sum[item] = _.reduce(_.pluck(_.where(data, shop:shop), item), ((memo, s) ->
          memo + s
        ), 0)
        return
      stat[shop] = [sum['approve_count'], sum['approve2_count'], sum['total_count']]
      return

    stat_prev = {}
    date1 = new Date(Date.parse($('input[name=date1]').val()))
    #dtt1 = new Date(date1-60*1000*60*60*24)

    dtt1 = date1.addDays(-60);

    d = dtt1.getDate()
    m = dtt1.getMonth()+1
    d = if d < 10 then '0' + d else d
    m = if m < 10 then '0' + m else m
    dt1 = '' + dtt1.getFullYear() + '-' + m + '-' + d

    date2 = new Date(Date.parse($('input[name=date1]').val()))
    console.log(dtt1, date2)
    #date2 = new Date(dtt2)
    m = date2.getMonth()+1
    d = date2.getDate()
    d = if d < 10 then '0' + d else d
    m = if m < 10 then '0' + m else m
    dt2 = '' + date2.getFullYear() + '-' + m + '-' + d
    
    url_pp = "?date1="+dt1+
            "&date2="+dt2+
            "&managers="+$('select[name=managers]').val()+
            "&shops="+$('select[name=shops]').val() +
            "&ch1="+$('input[name=ch1]').val() +
            "&ch2="+$('input[name=ch2]').val()
            
    $.ajax(url: "salary/ex_total" + url_pp).done (data) ->
      stat_prev = {}
      shops = _.uniq(_.pluck(data, 'shop'))
      shops.forEach (shop) ->
        sum = {}
        ['buy_count','approve_count'].forEach (item) ->
          sum[item] = _.reduce(_.pluck(_.where(data, shop:shop), item), ((memo, s) ->
            memo + s
          ), 0)
          return
        df = _.where(data, shop:shop)
        stat_prev[shop] = [sum['buy_count'], sum['approve_count'], df]
        return
    
    
      $.ajax(url: "salary/ex_total" + url_p).done (data) ->
        t = data
        $.map data, (item) ->
          calc item, stat, stat_prev
        data = _.map data, (item) ->
          _.values(_.omit(item, 'id', 'approve_sum', 'buy_sum'))
        columns_ = _.rest(columns)
        ttt1 = data
        ttt11 = t
        [{el: '#output1', group_col: 0, columns: columns_, gr: 'manager'}, {el: '#output2', group_col: 1, columns: columns_, gr: 'shop'}].forEach (it) ->
          render_tbl(data, t, it, 0)
        return
        
      detail = $('select[name=detail]').val()
      if detail == 'week'
        url = 'ex_week'
      else if detail == 'month'
        url = 'ex_month'
      else
        url = 'ex_day'
        
      $.ajax(url: 'salary/' + url + url_p).done (data) ->
        gd = data
        t = data
        
        $.map data, (item) ->
          calc item, stat, stat_prev
        data = _.map data, (item) ->
          _.values(_.omit(item, 'id', 'approve_sum', 'buy_sum'))
        ttt2 = data
        ttt22 = t
        render_tbl(data, t, {el: '#output', group_col: 0, columns: columns, gr: 'date'}, 1)
        render_gr()
        return

      $.ajax(url: 'salary/ex_distribution' + url_p).done (data) ->
        render_gr_distribution(data)
        return
   
      return
    
  return

$('.index.admin_salary').ready ->
  ['#output','#output1','#output2'].forEach (el) ->
    $(el).mouseenter ->
      window.ht = $(this).find( "thead" ).clone()
      window.ht.appendTo( $(this) ).addClass('headerstat')
      return
    $(el).mouseleave ->
      window.ht.remove()
      return
  $('#datepicker1').datepicker({ dateFormat: 'yy-mm-dd' })
  $('#datepicker2').datepicker({ dateFormat: 'yy-mm-dd' })
  d = new Date
  curr_date = d.getDate()
  curr_month = d.getMonth() + 1
  curr_month = if curr_month < 10 then '0' + curr_month else curr_month
  curr_year = d.getFullYear()
  db = undefined
  if curr_date > 15
    db = '16'
    de = new Date(curr_year, curr_month, 0).getDate()
  else
    db = '01'
    de = '15'
  $('input[name=date1]').val curr_year + '-' + curr_month + '-' + db
  $('input[name=date2]').val curr_year + '-' + curr_month + '-' + de
  $('.chosen-select').chosen()
  render_all()
  
  $('#update').click ->
    $('#output').html ''
    $('#output1').html ''
    $('#output2').html ''
    render_all()
    return 

  $('#update_col').click ->
    $('#output').html ''
    $('#output1').html ''
    $('#output2').html ''
    render_col()
    return 
  
  _.range(25).forEach (i) ->
    $('#b'+i).change ->
      if $(this).is(":checked")
        hidden_cols_g = _.without(hidden_cols_g, i+2)
      else
        hidden_cols_g.push(i+2)
        hidden_cols_g = _.uniq(hidden_cols_g)
      return
    
  $('#update_gr').click ->
    render_gr()
    return
    
  $('#curr').click ->
    d = new Date
    curr_date = d.getDate()
    curr_month = d.getMonth() + 1
    curr_month = if curr_month < 10 then '0' + curr_month else curr_month
    curr_year = d.getFullYear()
    db = undefined
    if curr_date > 15
      db = '16'
      de = new Date(curr_year, curr_month, 0).getDate()
    else
      db = '01'
      de = '15'
    $('input[name=date1]').val curr_year + '-' + curr_month + '-' + db
    $('input[name=date2]').val curr_year + '-' + curr_month + '-' + de
    return
    
  $('#prev').click ->
    d = new Date
    curr_date = d.getDate()
    curr_month = d.getMonth() + 1
    curr_month = if curr_month < 10 then '0' + curr_month else curr_month
    curr_year = d.getFullYear()
    db = undefined
    if curr_date > 15
      db = '01'
      de = '15'
    else
      db = '16'
      d.setMonth d.getMonth()
      d.setDate 0
      de = d.getDate()
      curr_month = d.getMonth() + 1
      curr_month = if curr_month < 10 then '0' + curr_month else curr_month
    $('input[name=date1]').val curr_year + '-' + curr_month + '-' + db
    $('input[name=date2]').val curr_year + '-' + curr_month + '-' + de
    return
