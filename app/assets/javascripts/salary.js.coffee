calc = (item) ->
  ap = 100*item.approve_count/item.total_count
  bp = 0
  if item.approve_count != 0 then (bp = 100*item.buy_count/item.approve_count)
  rp = 0
  if item.approve_count != 0 then (rp = 100*item.ret_count/item.approve_count)
  brp = 0
  if item.approve_count != 0 then (brp = 100*(item.buy_count+item.ret_count)/item.approve_count)
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
  _.extend(item, { ap:Math.round(ap), bp:Math.round(bp), rp:Math.round(rp), brp:Math.round(brp), z:Math.round(z), z_total:Math.round(z_total) })
  
render_all = ->
  $.ajax(url: "salary/ex2"+"?date1="+$('input[name=date1]').val()+"&date2="+$('input[name=date2]').val()+"&managers="+$('select[name=managers]').val()+"&shops="+$('select[name=shops]').val()).done (data) ->
    t = data
    $.map data, (item) ->
      calc item

    data = _.map data, (item) ->
      _.values(_.omit(item, 'id', 'approve_sum'))
 
    $('#output1').DataTable
      destroy: true
      data: data
      'displayLength': 100
      columnDefs: [
        { "visible": false, "targets": 0 }
      ],
      columns: [
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
        { title: 'Оплата/заказ' }
        { title: 'Оплата' }
      ]
      "order": [[ 0, "asc" ], [ 13, "desc" ]]
      "drawCallback": (settings) ->
        api = @api()
        rows = api.rows(page: 'current').nodes()
        sum = _.reduce(_.pluck(t, 'z_total'), ((memo, s) ->
          memo + s
        ), 0)
        sum_t = _.reduce(_.pluck(t, 'total_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_a = _.reduce(_.pluck(t, 'approve_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_b = _.reduce(_.pluck(t, 'buy_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_r = _.reduce(_.pluck(t, 'ret_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_h = _.reduce(_.pluck(t, 'hold_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_c = _.reduce(_.pluck(t, 'cancel_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_s = _.reduce(_.pluck(t, 'approve_sum'), ((memo, s) ->
          memo + s
        ), 0)
        ch = Math.round(sum_s / sum_a)
        ap = Math.round(100 * sum_a / sum_t)
        bp = 0
        if sum_a !=0 then (bp = Math.round(100 * sum_b / sum_a))
        rp = 0
        if sum_a !=0 then (rp = Math.round(100 * sum_r / sum_a))
        brp = 0
        if sum_a !=0 then (brp = Math.round(100 * (sum_b+sum_r) / sum_a))
        z = Math.round(sum / sum_a)
        $(rows).eq(0).before '<tr class="group"><td>' + 'Итого' + '</td><td>' + sum_t + '</td><td>' + sum_a + '</td><td>' + sum_b + '</td><td>' + sum_r + '</td><td>' + sum_c + '</td><td>' + sum_h + '</td><td>' + ch + '</td><td>'+ ap + '</td><td>'+ bp + '</td><td>' + rp + '</td><td>' + brp + '</td><td>' + z + '</td><td>' + sum + '</td></tr>'
        last = null
        api.column(0, page: 'current').data().each (group, i) ->
          if last != group
            tt = _.where(t, {manager: group})
            sum = _.reduce(_.pluck(tt, 'z_total'), ((memo, s) ->
              memo + s
            ), 0)
            sum_t = _.reduce(_.pluck(tt, 'total_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_a = _.reduce(_.pluck(tt, 'approve_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_b = _.reduce(_.pluck(tt, 'buy_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_r = _.reduce(_.pluck(tt, 'ret_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_h = _.reduce(_.pluck(tt, 'hold_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_c = _.reduce(_.pluck(tt, 'cancel_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_s = _.reduce(_.pluck(tt, 'approve_sum'), ((memo, s) ->
              memo + s
            ), 0)
            ch = Math.round(sum_s / sum_a)
            ap = Math.round(100 * sum_a / sum_t)
            bp = 0
            if sum_a !=0 then (bp = Math.round(100 * sum_b / sum_a))
            rp = 0
            if sum_a !=0 then (rp = Math.round(100 * sum_r / sum_a))
            brp = 0 
            if sum_a !=0 then (brp = Math.round(100 * (sum_b+sum_r) / sum_a))
            z = Math.round(sum / sum_a)
            $(rows).eq(i).before '<tr class="group"><td>' + group + '</td><td>' + sum_t + '</td><td>' + sum_a + '</td><td>' + sum_b + '</td><td>' + sum_r + '</td><td>' + sum_c + '</td><td>' + sum_h + '</td><td>' + ch + '</td><td>' + ap + '</td><td>' + bp + '</td><td>' + rp + '</td><td>' + brp + '</td><td>' + z + '</td><td>' + sum + '</td></tr>'
            last = group
          return
        return

    $('#output2').DataTable
      destroy: true
      data: data
      'displayLength': 100
      columnDefs: [
        { "visible": false, "targets": 1 }
      ],
      columns: [
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
        { title: 'Оплата/заказ' }
        { title: 'Оплата' }
      ]
      "order": [[ 1, "asc" ], [ 13, "desc" ]]
      "drawCallback": (settings) ->
        api = @api()
        rows = api.rows(page: 'current').nodes()
        sum = _.reduce(_.pluck(t, 'z_total'), ((memo, s) ->
          memo + s
        ), 0)
        sum_t = _.reduce(_.pluck(t, 'total_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_a = _.reduce(_.pluck(t, 'approve_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_b = _.reduce(_.pluck(t, 'buy_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_r = _.reduce(_.pluck(t, 'ret_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_h = _.reduce(_.pluck(t, 'hold_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_c = _.reduce(_.pluck(t, 'cancel_count'), ((memo, s) ->
          memo + s
        ), 0)
        sum_s = _.reduce(_.pluck(t, 'approve_sum'), ((memo, s) ->
          memo + s
        ), 0)
        ch = Math.round(sum_s / sum_a)
        ap = Math.round(100 * sum_a / sum_t)
        bp = 0
        if sum_a !=0 then (bp = Math.round(100 * sum_b / sum_a))
        rp = 0
        if sum_a !=0 then (rp = Math.round(100 * sum_r / sum_a))
        brp = 0
        if sum_a !=0 then (brp = Math.round(100 * (sum_b+sum_r) / sum_a))
        z = Math.round(sum / sum_a)
        $(rows).eq(0).before '<tr class="group"><td>' + 'Итого' + '</td><td>' + sum_t + '</td><td>' + sum_a + '</td><td>' + sum_b + '</td><td>' + sum_r + '</td><td>' + sum_c + '</td><td>' + sum_h + '</td><td>' + ch + '</td><td>' + ap + '</td><td>' + bp + '</td><td>' + rp + '</td><td>' + brp + '</td><td>' + z + '</td><td>' + sum + '</td></tr>'
        last = null
        api.column(1, page: 'current').data().each (group, i) ->
          if last != group
            tt = _.where(t, {shop: group})
            sum = _.reduce(_.pluck(tt, 'z_total'), ((memo, s) ->
              memo + s
            ), 0)
            sum_t = _.reduce(_.pluck(tt, 'total_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_a = _.reduce(_.pluck(tt, 'approve_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_b = _.reduce(_.pluck(tt, 'buy_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_r = _.reduce(_.pluck(tt, 'ret_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_h = _.reduce(_.pluck(tt, 'hold_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_c = _.reduce(_.pluck(tt, 'cancel_count'), ((memo, s) ->
              memo + s
            ), 0)
            sum_s = _.reduce(_.pluck(tt, 'approve_sum'), ((memo, s) ->
              memo + s
            ), 0)
            ch = Math.round(sum_s / sum_a)
            ap = Math.round(100 * sum_a / sum_t)
            bp = 0
            if sum_a !=0 then (bp = Math.round(100 * sum_b / sum_a))
            rp = 0
            if sum_a !=0 then (rp = Math.round(100 * sum_r / sum_a))
            brp = 0
            if sum_a !=0 then (brp = Math.round(100 * (sum_b+sum_r) / sum_a))
            z = Math.round(sum / sum_a)
            $(rows).eq(i).before '<tr class="group"><td>' + group + '</td><td>' + sum_t + '</td><td>' + sum_a + '</td><td>' + sum_b + '</td><td>' + sum_r + '</td><td>' + sum_c + '</td><td>' + sum_h + '</td><td>' + ch + '</td><td>' + ap + '</td><td>' + bp + '</td><td>' + rp + '</td><td>' + brp + '</td><td>' + z + '</td><td>' + sum + '</td></tr>'
            last = group
          return
        return
    
  $.ajax(url: "salary/ex"+"?date1="+$('input[name=date1]').val()+"&date2="+$('input[name=date2]').val()+"&managers="+$('select[name=managers]').val()+"&shops="+$('select[name=shops]').val()).done (data) ->
    $.map data, (item) ->
      calc item
      
    data = _.map data, (item) ->
      _.values(_.omit(item, 'id'))
 
    $('#output').DataTable
      destroy: true
      data: data
      'displayLength': 25
      columns: [
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
        { title: 'Оплата/заказ' }
        { title: 'Оплата' }
      ]
      "order": [[ 0, "asc" ],[ 1, "asc" ],[ 2, "asc" ]]
      
    $('.spinner').hide()
    
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
