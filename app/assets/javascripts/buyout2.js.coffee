render = ->
  p_shops = $('select[name=shops]').val()
  p_managers = $('select[name=ms]').val()
  $.ajax(url: 'buyout2/ex?shops='+p_shops).done (data) ->
    data3=[]
    data4=[]
    data2 =_.groupBy(data, 'dto')
    
    for key of data2
      elm = {}
      elm['dto']=key
      sum = _.reduce(_.pluck(data2[key], 'srok_vikupa'), ((memo, s) ->
        memo + s
      ), 0)
      datam = _.groupBy(data2[key], 'manager')
      for keym of datam
        summ = _.reduce(_.pluck(datam[keym], 'srok_vikupa'), ((memo, s) ->
          memo + s
        ), 0)
        cntm = datam[keym].length
        elm[keym]=Math.round(summ/cntm)
      cnt = data2[key].length
      elm['Среднее']=Math.round(sum/cnt)
      data4.push(elm)
      el={'dto': key, 'Среднее':Math.round(sum/cnt), 'cnt':cnt}
      data3.push(el)

    if !p_managers
      p_managers=[]
    p_managers.push 'Среднее'
    Morris.Line
      element: 'graph'
      data: data4
      xkey: 'dto'
      ykeys: p_managers
      labels: p_managers
      lineWidth: 2
      parseTime: false
      xLabelAngle:90
      
    Morris.Line
      element: 'graph2'
      data: data3
      xkey: 'dto'
      ykeys: [
        'cnt'
      ]
      labels: [
        'Кол-во'
      ]
      lineWidth: 2
      parseTime: false
      xLabelAngle:90
      
    if p_shops && p_managers.length>1
      m = p_managers[0]
      $('#manager').html(m)
      dm = _.where(data, { 'manager' : m })
      Morris.Line
        element: 'graph3'
        data: dm
        xkey: 'dto'
        ykeys: [
          'srok_vikupa'
        ]
        labels: [
          'Срок выкупа'
        ]
        lineWidth: 2
        parseTime: false    
    
   return
  
$('.index.admin_buyout2').ready ->
  $('.chosen-select').chosen()
  render()
  
  $('#update').click ->
    $('#graph').html ''
    $('#graph2').html ''
    $('#graph3').html ''
    render()
  return
  
  return