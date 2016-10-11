gd = []

calc = (item) ->
  ap = 100*item.approve_count/item.total_count
  bp = 0
  rp = 0
  brp = 0
  if item.approve_count != 0
    bp = 100*item.buy_count/item.approve_count
    rp = 100*item.ret_count/item.approve_count
    brp = 100*(item.buy_count+item.ret_count)/item.approve_count
  z = 0
  if item.shop=='Бриджи Hot Shapers'
    z = parseFloat((25.485272*Math.exp(0.145843*((item.ch-2250)/100))).toFixed(2))*ap/70
  else if item.shop=='Бриджи Hot Shapers Казахстан'
    z = parseFloat((25.485272*Math.exp(0.145843*((item.ch-2250)/100))).toFixed(2))*ap/70
  else if item.shop=='Золотые цепочки'
    z = parseFloat((25.485272*Math.exp(0.145843*((item.ch-2250)/100))).toFixed(2))*ap/75
  else if item.shop=='Пояс HS'
    z = parseFloat((25.485272*Math.exp(0.145843*((item.ch-2250)/100))).toFixed(2))*ap/70
  else
    z = 0
  if z>250
    z = 250
  z_total = z*item.approve_count     
  _.extend(item, { ap:Math.round(ap), bp:Math.round(bp), rp:Math.round(rp), brp:Math.round(brp), z: Math.round(z), z_total: Math.round(z_total) })
  return
  
calc_t = (data, group, v) ->
  sum = {}
  ['z_total',  'total_count', 'approve_count', 'buy_count', 'ret_count', 'hold_count', 'cancel_count', 'approve_sum'].forEach (item) ->
    sum[item] = _.reduce(_.pluck(data, item), ((memo, s) ->
      memo + s
    ), 0)
    return
  sum['ap'] = Math.round(100 * sum['approve_count'] / sum['total_count'])
  sum['ch'] = 0
  sum['bp'] = 0
  sum['rp'] = 0
  sum['brp'] = 0
  sum['z'] = 0
  if sum['approve_count'] != 0
    sum['ch'] = Math.round(sum['approve_sum'] / sum['approve_count'])
    sum['bp'] = Math.round(100 * sum['buy_count'] / sum['approve_count'])
    sum['rp'] = Math.round(100 * sum['ret_count'] / sum['approve_count'])
    sum['brp'] = Math.round(100 * (sum['buy_count'] + sum['ret_count']) / sum['approve_count'])  
    sum['z'] = Math.round(sum['z_total'] / sum['approve_count'])
  gs = '<td>'
  if v==1 then (gs='<td colspan="2">')
  return '<tr class="group">'+ gs + group + '</td><td>' + sum['total_count'] + '</td><td>' + sum['approve_count'] + '</td><td>' + sum['buy_count'] + '</td><td>' + sum['ret_count'] + '</td><td>' + sum['cancel_count'] + '</td><td>' + sum['hold_count'] + '</td><td>' + sum['ch'] + '</td><td>'+ sum['ap'] + '</td><td>'+ sum['bp'] + '</td><td>' + sum['rp'] + '</td><td>' + sum['brp'] + '</td><td>' + sum['z'] + '</td><td>' + sum['z_total'] + '</td></tr>'

columns = [
  { title: 'Дата' }
  { title: 'Менеджер' }
  { title: 'Магазин' }
  { title: 'Всего' }
  { title: 'Апрув' }
  { title: 'Выкуплен' }
  { title: 'Возврат' }
  { title: 'Отмена' }
  { title: 'Холд' }
  { title: 'Ср.чек' }
  { title: 'Апрув(%)' }
  { title: 'Выкуплен(%)' }
  { title: 'Возврат(%)' }
  { title: 'Выполнен(%)' }
  { title: 'Опл/заказ' }
  { title: 'Оплата' }
]

render_tbl = (data, t, it, v) ->
  $(it.el).DataTable
    destroy: true
    data: data
    displayLength: 100
    "columnDefs": [
      { "visible": false, "targets": it.group_col }
    ],
    columns: it.columns
    order: [[ it.group_col, "asc" ], [ 14, "desc" ]]
    drawCallback: (settings) ->
      api = @api()
      rows = api.rows().nodes()
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
      _.extend(d3, {dt: key})
      d.push(d3)
  
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
  
render_all = ->
  url_p = "?date1="+$('input[name=date1]').val()+
          "&date2="+$('input[name=date2]').val()+
          "&managers="+$('select[name=managers]').val()+
          "&shops="+$('select[name=shops]').val()
  $.ajax(url: "salary/ex_total" + url_p).done (data) ->
    t = data
    $.map data, (item) ->
      calc item
    data = _.map data, (item) ->
      _.values(_.omit(item, 'id', 'approve_sum'))
    columns_ = _.rest(columns)
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
      calc item
    data = _.map data, (item) ->
      _.values(_.omit(item, 'id', 'approve_sum'))
 
    render_tbl(data, t, {el: '#output', group_col: 0, columns: columns, gr: 'date'}, 1)
    render_gr()
    return

  return

$('.index.admin_salary').ready ->
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
    d.setDate 0
    de = d.getDate()
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
      d.setDate 0
      de = d.getDate()
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
