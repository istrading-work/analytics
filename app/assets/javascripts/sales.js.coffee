gd = []

calc = (item) ->

  bch = 0
  if item.buy_count != 0
    bch = item.buy_sum / item.buy_count
  ap = 100*item.approve_count/item.total_count
  a2p = 100*item.approve2_count/item.total_count
      
  bp = 0
  rp = 0
  brp = 0
  if item.approve_count != 0
    bp = 100*item.buy_count/item.approve_count
    rp = 100*item.ret_count/item.approve_count
    brp = 100*(item.buy_count+item.ret_count)/item.approve_count
    
  _.extend(item, { bch:Math.round(bch), ap:Math.round(ap), a2p:Math.round(a2p), bp:Math.round(bp), rp:Math.round(rp), brp:Math.round(brp)})
  return
  
calc_t = (data, group, v) ->
  sum = {}
  ['total_count', 'approve_count', 'approve2_count', 'buy_count', 'ret_count', 'hold_count', 'cancel_count', 'approve_sum', 'buy_sum'].forEach (item) ->
    sum[item] = _.reduce(_.pluck(data, item), ((memo, s) ->
      memo + s
    ), 0)
    return
  sum['ap'] = Math.round(100 * sum['approve_count'] / sum['total_count'])
  sum['a2p'] = Math.round(100 * sum['approve2_count'] / sum['total_count'])
  sum['ch'] = 0
  sum['bch'] = 0
  sum['bp'] = 0
  sum['rp'] = 0
  sum['brp'] = 0
  if sum['approve_count'] != 0
    sum['ch'] = Math.round(sum['approve_sum'] / sum['approve_count'])
    sum['bp'] = Math.round(100 * sum['buy_count'] / sum['approve_count'])
    sum['rp'] = Math.round(100 * sum['ret_count'] / sum['approve_count'])
    sum['brp'] = Math.round(100 * (sum['buy_count'] + sum['ret_count']) / sum['approve_count'])  
  if sum['buy_count'] != 0  
    sum['bch'] = Math.round(sum['buy_sum'] / sum['buy_count'])
  gs = '<td>'
  if v==1 then (gs='<td colspan="2">')
  return '<tr class="group">'+ gs + group + '</td><td>' + sum['total_count'] + '</td><td>' + sum['approve_count'] + '</td><td>' + sum['approve2_count'] + '</td><td>' + sum['buy_count'] + '</td><td>' + sum['ret_count'] + '</td><td>' + sum['cancel_count'] + '</td><td>' + sum['hold_count'] + '</td><td>' + sum['ch'] + '</td><td>' + sum['bch'] + '</td><td>' + sum['ap'] + '</td><td>' + sum['a2p'] + '</td><td>' + sum['bp'] + '</td><td>' + sum['rp'] + '</td><td>' + sum['brp'] + '</td></tr>'

columns = [
  { title: 'Дата' }
  { title: 'Магазин' }
  { title: 'Всего' }
  { title: 'Апрув' }
  { title: 'Апрув&nbsp;+' }
  { title: 'Выкуп' }
  { title: 'Возврат' }
  { title: 'Отмена' }
  { title: 'Холд' }
  { title: 'Ср.чек' }
  { title: 'Ср.чек выкуп' }
  { title: 'Апрув(%)' }
  { title: 'Апрув&nbsp;+(%)' }
  { title: 'Выкуп(%)' }
  { title: 'Возврат(%)' }
  { title: 'Выполнен(%)' }
]

render_tbl2 = (data, t, it, v) ->
  $(it.el).DataTable
    destroy: true
    data: data
    displayLength: 100
    columns: it.columns
    drawCallback: (settings) ->
      api = @api()
      rows = api.rows().nodes()
      $(rows).eq(0).before calc_t(t, 'Итого', v)
      return
  return
  
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
  
render_all = ->
  if not $('select[name=shops]').val()
    $('select[name=shops]').prop('selected', true);

  url_p = "?date1="+$('input[name=date1]').val()+
          "&date2="+$('input[name=date2]').val()+
          "&shops="+$('select[name=shops]').val() +
          "&ch1="+$('input[name=ch1]').val() +
          "&ch2="+$('input[name=ch2]').val()

  $.ajax(url: "sales/ex_total" + url_p).done (data) ->
    t = data
    $.map data, (item) ->
      calc item
    data = _.map data, (item) ->
      _.values(_.omit(item, 'id', 'approve_sum', 'buy_sum'))
    columns_ = _.rest(columns)
    [{el: '#output1', group_col: -1, columns: columns_, gr: 'manager'}, {el: '#output2', group_col: 1, columns: columns_, gr: 'shop'}].forEach (it) ->
      render_tbl2(data, t, it, 0)
    return
    
  detail = $('select[name=detail]').val()
  if detail == 'week'
    url = 'ex_week'
  else if detail == 'month'
    url = 'ex_month'
  else
    url = 'ex_day'
    
  $.ajax(url: 'sales/' + url + url_p).done (data) ->
    gd = data
    t = data
    $.map data, (item) ->
      calc item
    data = _.map data, (item) ->
      _.values(_.omit(item, 'id', 'approve_sum', 'buy_sum'))
 
    render_tbl(data, t, {el: '#output', group_col: 0, columns: columns, gr: 'date'}, 0)
    return

  $.ajax(url: 'sales/ex_distribution' + url_p).done (data) ->
    render_gr_distribution(data)
    return

  return

$('.index.admin_sales').ready ->
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
