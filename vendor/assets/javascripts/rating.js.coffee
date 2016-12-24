render = (item) ->
  $.ajax(url: "rating/ex_"+item).done (data) ->
    console.log(data)
    $('#'+item).DataTable
      destroy: true
      data: data
      columns: [
        { title: 'Менеджер' }
        { title: 'Рейтинг' }
        { title: 'Приоритет' }
      ]
      "paging":   false
      "ordering": false
      "info":     false
  return

$('.index.admin_rating').ready ->
  ['before_last','last','curr'].forEach (item) ->
    render(item)
  return

ready = (m) ->
  alert(m)
  return
