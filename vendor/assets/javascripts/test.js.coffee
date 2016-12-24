$('.index.admin_report3').ready ->
  $.ajax(url: "report3/ex").done (data) ->
    sum = $.pivotUtilities.aggregatorTemplates.sum
    numberFormat = $.pivotUtilities.numberFormat
    intFormat = numberFormat(digitsAfterDecimal: 0)
    heatmap =  $.pivotUtilities.renderers["Col Heatmap"];
    $('.test1').pivotUI data,
      derivedAttributes:
       'month day': $.pivotUtilities.derivers.dateFormat("dt", "%m %d"),
       'month': $.pivotUtilities.derivers.dateFormat("dt", "%m"),
      rows: [ 'shop' ]
      cols: [ 'manager' ]
      aggregator: sum(intFormat)([ 'total_sum' ])
      renderer: heatmap
    $('.spinner').hide()
