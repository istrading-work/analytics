render = (url, total_sel, output, spinner) ->
  $(spinner).show()
  $.ajax(url: url+"?date1="+$('input[name=date1]').val()+"&date2="+$('input[name=date2]').val()+"&delivery_types="+$('select[name=delivery_types]').val()+"&shops="+$('select[name=shops]').val()).done (data) ->
    sum = _.reduce data, ((memo, obj) ->
      memo + obj.k
    ), 0
    
    _.map data, (obj) ->
      _.extend obj, p: Math.round 100 * obj.k / sum

    $(total_sel).html(sum)
    Morris.Line
      element: output
      data: data
      xkey: 'delta'
      ykeys: [
        'k'
        'p'
      ]
      labels: [
        'Кол-во'
        '%'
      ]
      lineColors: [
        '#167f39'
        '#044c29'
      ]
      lineWidth: 2
      parseTime: false
    $(spinner).hide()
  return

render_all = ->
  i = 1
  while i <= 4
    $('#total'+i).html('')
    $('#output'+i).html('')
    render 'buyout/ex'+i, '#total'+i, 'output'+i, '#spinner'+i
    i++
  return
  
$('.index.admin_buyout').ready ->
  $('#datepicker1').datepicker({ dateFormat: 'yy-mm-dd' })
  $('#datepicker2').datepicker({ dateFormat: 'yy-mm-dd' })
  $('.chosen-select').chosen()
  
  render_all()

  $('#update').click ->
    render_all()
    return 

  return

