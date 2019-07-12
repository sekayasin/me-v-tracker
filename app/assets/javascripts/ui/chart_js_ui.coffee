class ChartJs.UI
  # Line chart configuration
  lineChart: (chartName, canvasId, Ylabels, datasets) ->
    chartCanvas = document.getElementById(canvasId).getContext('2d')
    newLineChart = new Chart(chartCanvas, {
      type: 'line',
      data: {
        labels: Ylabels,
        datasets: @lineChartDatasets(datasets, chartName)
      },
      options: {
        legend: position: "None",
        scales: {
          xAxes: [{
            display: true,
            gridLines: @gridLineX(),
            ticks: @xTicks(chartName)
          }],
          yAxes: [{
            display: true,
            gridLines: @gridLineY(),
            ticks: @yTicks(chartName),
            scaleLabel: @axisLabels(chartName),
          }]
        },
        title: display: false,
        tooltips: @toolTipsOptions(chartName)
      }
  })

  lineChartDatasets:(datasets, chartName) ->
    if chartName == 'outputQualityOverTime'
      [
        @primaryLine(datasets[0]),
        @dottedLine(datasets[1], 'outputQualityOverTime')
      ]
    else if chartName == 'performanceQualityOverTime'
      [
        @primaryLine(datasets[0]),
        @secondaryLine(datasets[1]),
        @dottedLine(datasets[2], 'performanceQualityOverTime')
      ]

  primaryLine:(dataset) ->
    {
      lineTension: 0,
      fill: false,
      label: dataset.label,
      data: dataset.data,
      backgroundColor: ['rgba(0, 0, 0, 0)'],
      borderColor: ['#3359DB'],
      borderWidth: 1.2,
      pointBackgroundColor: '#fff',
      pointHoverBackgroundColor: '#3359db',
      pointHoverBorderColor: '#3359db'
    }

  secondaryLine:(dataset) ->
    {
      lineTension: 0,
      fill: false,
      label: dataset.label,
      data: dataset.data,
      backgroundColor: ['ffaf30'],
      borderColor: ['#ffaf30'],
      borderWidth: 1.2,
      pointBackgroundColor: '#fff',
      pointHoverBackgroundColor: '#ffaf30',
      pointHoverBorderColor: '#ffaf30'
    }

  dottedLine:(dataset, chartName) ->
    if chartName == 'outputQualityOverTime'
      {
        lineTension: 0,
        borderDash: [10, 10],
        data: dataset.data,
        label: dataset.label,
        backgroundColor: ['rgba(0, 0, 0, 0)'],
        borderColor: ['#ffaf30'],
        borderWidth: 1,
        radius: 0,
        pointHoverRadius: 0,
      }
    else if chartName == 'performanceQualityOverTime'
      {
        lineTension: 0,
        borderDash: [10, 10],
        data: dataset.data,
        label: dataset.label,
        backgroundColor: ['rgba(0, 0, 0, 0)'],
        borderColor: ['#7e0aed'],
        borderWidth: 1,
        radius: 0,
        pointHoverRadius: 0,
      }

  axisLabels: (chartName) ->
    if chartName == 'outputQualityOverTime'
      {
        display: true,
        fontSize: 12,
        fontFamily: "DINPro-Light",
        padding: 10,
        labelString: "Output Expectation",
      }
    else if chartName == 'performanceQualityOverTime'
      {
        display: true,
        fontSize: 12,
        padding: 10,
        fontFamily: "DINPro-Light",
        labelString: "Satisfaction Level",
      }
  yAxisLabels: (chartName) ->
    if chartName == 'learnerQuantity'
      {
        display: true,
        fontSize: 12,
        fontFamily: "DINPro-Light",
        padding: 10,
        labelString: "No. of Learners",
      }

  xAxisLabels: (chartName) ->
    if chartName == 'learnerQuantity'
      {
        display: true,
        fontSize: 12,
        fontFamily: "DINPro-Light",
        padding: 10,
        labelString: "Fellowship Cycles",
      }

  gridLineX: ->
    {
      display: false,
    }

  gridLineY: ->
    {
      lineWidth: 0.7,
      tickMarkLength: 0,
      zeroLineWidth: 0
    }

  yTicks: (chartName) ->
    if chartName == 'outputQualityOverTime'
      {
        min: 0,
        max: 3,
        stepSize: 1,
        fontColor: '#737373',
        fontFamily: "DINPro-Light",
        fontSize: 12,
        fontStyle: 'normal',
        padding: 6
      }
    else if chartName == 'performanceQualityOverTime'
      {
        min: -2,
        max: 2,
        stepSize: 1,
        fontColor: '#737373',
        fontFamily: "DINPro-Light",
        fontSize: 12,
        fontStyle: 'normal',
        padding: 10
      }

  xTicks: (chartName) ->
    {
      fontColor: '#737373',
      fontFamily: "DINPro-Light",
      fontSize: 12,
      fontStyle: 'normal',
      padding: 10,
      maxRotation: 30
      autoSkip: false
    }

  toolTipsOptions: (chartName) ->
    if chartName == 'outputQualityOverTime'
      return @outputQualityTooltipOptions()
    else if chartName == 'performanceQualityOverTime'
      return @performanceQualityTooltipOptions()
    else if chartName == 'learnerQuantity'
      return @learnerQuantityTooltipOptions()
    else if chartName == 'lfaToLearnerRatio'
      return @lfaToLearnerRatioTooltipOptions()
    else if chartName == 'averagePerceivedReadinessAcrossCenters'
      return @perceivedReadinessAcrossCentersTooltipOptions()
    else if chartName == 'horizontalPerceivedReadinessAcrossGenders'
      return @perceivedReadinessAcrossGenders()
    { enabled: false }

  perceivedReadinessAcrossCentersTooltipOptions: ->
    {
      callbacks: @perceivedReadinessAcrossCentersCallback(),
      mode: 'point',
      cornerRadius: 5,
      caretSize: 0,
      xAlign: "center",
      xPadding: 5,
      yPadding: 18,
      bodySpacing: 15,
      borderColor: 'rgb(0, 0, 0)',
      titleFontColor: 'rgb(0, 0, 0)',
      bodyFontFamily: "DINPro-Light",
      backgroundColor: '#FFF',
      bodyFontColor: '#737373',
      labelColors: Color,
      labelFontStyle: 'bold'
    }
  perceivedReadinessAcrossCentersCallback:->
    {
      title: (data)->
        return data[0].yLabel
      label: (tooltipItem, data) ->
        data_ =  data.datasets[tooltipItem.datasetIndex]
        label = data_.label || '';
        if label
          label += ': '
        label += data_.data[tooltipItem.index] + "%";
        return label
      labelTextColor: (tooltipItem, chart) ->
        return 'rgba(0, 0, 0, 0.8)'
    }

  perceivedReadinessAcrossGenders:->
    {
      callbacks: @perceivedReadinessAcrossGendersCallback(),
      mode: 'point',
      cornerRadius: 5,
      caretSize: 0,
      xAlign: "center",
      xPadding: 5,
      yPadding: 18,
      bodySpacing: 15,
      titleFontColor: 'rgb(0, 0, 0)',
      bodyFontFamily: "DINPro-Light",
      backgroundColor: '#FFF',
      bodyFontColor: '#737373',
    }

  perceivedReadinessAcrossGendersCallback:->
    {
      title: (data)->
        return data[0].yLabel

      label: (tooltipItem, data) ->
        data_ =  data.datasets[tooltipItem.datasetIndex]
        label = data_.label || '';
        if label
          label += ': '
        label += data_.data[tooltipItem.index] + "%";
        return label

      labelColors: Color

      labelTextColor: (tooltipItem, chart) ->
        return 'rgba(0, 0, 0, 0.8)'
    }

  performanceQualityTooltipOptions: ->
    {
      callbacks: @performancetooltipCallback(),
      mode: 'index',
      borderColor: "rgba(151,151,151,0.2)",
      borderWidth: 1,
      cornerRadius: 5,
      caretSize: 0,
      xPadding: 5,
      yPadding: 18,
      bodySpacing: 15,
      bodyFontFamily: "DINPro-Light",
      backgroundColor: '#FFF',
      bodyFontColor: '#737373',
      bodyFontStyle: 'bold',
      bodyFontSize: 12
    }

  performancetooltipCallback: ->
    {
      title: (tooltipItems, data) ->
        return ""

      label: (tooltipItem, data) ->
        if tooltipItem.datasetIndex == 0
          actualLabel = data['datasets'][0].label
          labelData = tooltipItem.yLabel
          return "Actual: #{actualLabel} #{labelData}"

        else if tooltipItem.datasetIndex == 1
          actualLabel = data['datasets'][1].label
          labelData = tooltipItem.yLabel
          return "Actual: #{actualLabel} #{labelData}"
        else if tooltipItem.datasetIndex == 2
          targetLabel = data['datasets'][2].label
          labelData = tooltipItem.yLabel
          return "#{targetLabel} #{labelData}"

      labelColor: (tooltipItem, chart) ->
        return {
          borderColor: 'rgb(255, 255, 255)',
          backgroundColor: 'rgb(255, 255, 255)'
        }

      labelTextColor: (tooltipItem, chart) ->
        if tooltipItem.datasetIndex == 0
          return '#3359db'
        else if tooltipItem.datasetIndex == 1
          return '#ffaf30';
        else if tooltipItem.datasetIndex == 2
          return '#7e0aed'
    }

  outputQualityTooltipOptions: ->
    {
      callbacks: @outputQualityTooltipCallback()
      borderColor: "rgba(151,151,151,0.2)",
      borderWidth: 1,
      cornerRadius: 5,
      caretSize: 0,
      xPadding: 10,
      yPadding: 20,
      backgroundColor: '#fff',
      bodySpacing: 15,
      bodyFontFamily: "DINPro-Light",
      bodyFontStyle: 'bold',
      bodyFontSize: 12,
    }

  outputQualityTooltipCallback: ->
    {
      title: (tooltipItems, data) ->
        return ""

      label: (tooltipItem, data) ->
        actualLabel = data['datasets'][0].label
        labelData = tooltipItem.yLabel
        return "#{actualLabel}  #{labelData}"

      labelColor: (tooltipItem, chart) ->
        return {
            borderColor: 'rgb(255, 255, 255)',
            backgroundColor: 'rgb(255, 255, 255)'
        }

      labelTextColor: (tooltipItem, chart) ->
        return '#3359db';
    }

  learnerQuantityTooltipOptions: ->
    {
      callbacks: @learnerQuantityCallback()
      mode: 'index',
      borderColor: "rgba(151,151,151,0.2)",
      borderWidth: 1,
      cornerRadius: 5,
      caretSize: 0,
      xPadding: 5,
      yPadding: 18,
      bodySpacing: 15,
      footerSpacing: 10,
      titleMarginBottom: 17,
      footerMarginTop: 18,
      bodyFontFamily: "DINPro-Light",
      footerFontFamily: "DINPro-Light",
      backgroundColor: '#FFF',
      titleFontColor: '#3359DB',
      bodyFontColor: '#737373',
      footerFontColor: 'rgba(151,151,151,0.5)',
      footerFontStyle: 'normal',
      bodyFontStyle: 'normal',
      bodyFontSize: 12,
      titleFontSize: 12,
      displayColors: true,
    }

  learnerQuantityCallback: ->
    {
      title: (tooltipItem, data) ->
        return ( " " + data['datasets'][0]['label']+ " "+ tooltipItem[0]['yLabel'] + " ")

      label: -> ""
      footer: (tooltipItem, data) ->
        label = data['datasets'][tooltipItem[1]['datasetIndex']]['label']
        value = tooltipItem[1]['yLabel']
        percentage = Math.round(value * 100 / tooltipItem[0]['yLabel']) || 0
        return ( "     "+ label+ "                "+ value + ' [' + percentage + '%]')

      afterFooter: (tooltipItem, data) ->
        label = data['datasets'][tooltipItem[2]['datasetIndex']]['label']
        value = tooltipItem[2]['yLabel']
        percentage = Math.round(value * 100 / tooltipItem[0]['yLabel']) || 0
        return ( "     "+ label+ "             "+ value + ' [' + percentage + '%]')

      labelColor: (tooltipItem, chart) ->
        return {
            borderColor: 'rgb(255, 255, 255)',
            backgroundColor: 'rgb(255, 255, 255)'
        }
      labelTextColor: (tooltipItem, chart) ->
        return 'rgba(151,151,151,0.8)'
    }

  lfaToLearnerRatioTooltipOptions: ->
    {
      callbacks: @ratiotooltipCallback(),
      mode: 'nearest',
      borderColor: "rgba(151,151,151,0.2)",
      borderWidth: 1,
      cornerRadius: 5,
      caretSize: 0,
      xPadding: 1,
      yPadding: 4,
      bodySpacing: 7,
      bodyFontFamily: "DINPro-Light",
      backgroundColor: '#FFF',
      bodyFontColor: '#737373',
      bodyFontStyle: 'bold',
      bodyFontSize: 12
    }


  ratiotooltipCallback: ->
    {
      title: -> ""
      label: (tooltipItem, data) ->
        dataset = data.datasets[tooltipItem.datasetIndex]
        dataList = [[dataset.data[0]], [dataset.data[1]]]
        switch tooltipItem.yLabel
          when "Week 1"
            if tooltipItem.datasetIndex == 0
              '1      :    ' + Math.round(((100 - dataList[0][0] ) / dataList[0][0]))
            else
              'LFA  :  Learner' + '   '
          when "Week 2"
            if tooltipItem.datasetIndex == 0
              '1      :    ' + Math.round(((100 - dataList[1][0]) / dataList[1][0]))
            else
              'LFA  :  Learner' + '   '
      labelColor: -> {
          borderColor: 'rgb(255, 255, 255)',
          backgroundColor: 'rgb(255, 255, 255)'
      }
      labelTextColor: -> '#000000'
    }


  generateLegend: (labels, colors, totals) ->
    text = []
    for index in [0...labels.length]
      text.push("""
        <div class='legend'>
          <span class='pull-left legend-circle' style='background: #{colors[index]}'></span>
          <span class='pull-left legend-text'>#{labels[index]}: #{totals[index]}</span>
          <div style='clear: both'></div>
        </div>
      """)
    return text.join('')

  # pie chart configuration
  pieChart:(chartName, canvasId, labels, data, colors, rotation, totals = null) ->
    self = @
    $('#optionsDistributionChart').remove()
    $('#optionsChartContainer').append('<canvas id="optionsDistributionChart" height="162px"></canvas>')
    pieCanvas = document.getElementById(canvasId).getContext('2d')
    newPieChart = new Chart(pieCanvas, {
     type: 'pie',
     data: {
       labels: labels,
       datasets: [
         {
           backgroundColor: colors,
           hoverBackgroundColor: colors,
           hoverBorderColor: 'rgba(0,0,0,0)',
           data: data,
           borderWidth: 0,
         }
       ]
     },
     options: {
       animation: {
         duration: 0
       },
       rotation: rotation,
       legend: false,
       legendCallback: -> self.generateLegend(labels, colors, totals),
       tooltips: {
         callbacks: {
           title: (tooltipItem) ->
            # following line should be removed to apply to other pie charts
            return "" unless totals?
            total = totals[tooltipItem[0].index]
            return "Total count    " + total if total
           label: (tooltipItem, data) ->
             dataset = data.datasets[tooltipItem.datasetIndex]
             text = data.labels[tooltipItem.index]
             currentValue = dataset.data[tooltipItem.index]
             return text + "   " + currentValue + "%"
         },
         xPadding: 10,
         yPadding: 10,
         titleMarginBottom: 10,
         borderColor: "rgba(151,151,151,0.2)",
         borderWidth: 1,
         cornerRadius: 5,
         caretSize: 2,
         bodySpacing: 10,
         backgroundColor: '#FFF',
         titleFontColor: '#3359DB',
         bodyFontColor: '#737373',
         bodyFontSize: 12,
         titleFontSize: 12,
         displayColors: true
       }
     }
   })

  # horizontalBar chart configuration
  horizontalBar:(chartName, canvasId, data, labels) ->
    self = @
    chartCanvas = document.getElementById(canvasId).getContext('2d')
    stackColumns = chartName != "lfaToLearnerRatio" && chartName != 'optionsDistibutionHorizontalBar'
    axisThickness = 40
    if chartName == "lfaToLearnerRatio"
      axisThickness = 29
    else if chartName == "horizontalPerceivedReadinessAcrossGenders"
      axisThickness = 50
    else if chartName == "optionsDistibutionHorizontalBar"
      axisThickness = 40
    newHorizontalBar = new Chart(chartCanvas, {
      type: 'horizontalBar',
      data: {
        labels: labels,
        datasets: data.datasets
      },
      options: {
        animation: {
          duration: 0,
          onComplete: ->
            ctx = this.chart.ctx
            ctx.textAlign = 'center'
            ctx.fontWeight= '500'
            ctx.textBaseline = 'bottom'
            ctx.font = 'normal 9px DINPro'
            for dataset in this.data.datasets
              for index, value of dataset.data
                for key, value of dataset._meta
                  model = dataset._meta[key].data[index]._model
                  if dataset.data[index] == data.datasets[0].data[index]
                    ctx.fillStyle = "#fff"
                    widthPercentage = model.x/this.chart.width * 100
                    xPosition =
                      if widthPercentage >= 60
                        model.x/2.0
                      else if widthPercentage >= 10
                        model.x - 15
                      else
                        model.x + 10
                    if ctx.canvas.id == "optionsDistributionHorizontalBar"
                      ctx.fillStyle = "#000"
                      ctx.font = 'normal 12px DINPro'
                      ctx.fillText(data.actualData.firstLabel[index], model.x + 28, model.y + 8)
                    else if ctx.canvas.id == "pictureOptionsDistributionHorizontalBar"
                      ctx.fillStyle = "#000"
                      ctx.font = 'normal 12px DINPro'
                      ctx.fillText(data.actualData.firstLabel[index], model.x + 24, model.y + 4)
                    else
                      ctx.fillText(data.actualData.firstLabel[index], xPosition, model.y + 10)
                  else if dataset.data[index] == data.datasets[1].data[index]
                    ctx.fillStyle = "#fff"
                    ctx.fillText(data.actualData.secondLabel[index], model.x - 15, model.y + 10)
                    if ctx.canvas.id == "historicalCenterAndGenderDistributionChart"
                      ctx.fillStyle = "#000"
                      ctx.fillText(data.actualData.firstLabel[index] + data.actualData.secondLabel[index], model.x + 15, model.y + 10)
                  else
                    ctx.fillStyle = "#fff"
                    ctx.fillText(data.actualData.thirdLabel[index], model.x - 15, model.y + 10)
                    if ctx.canvas.id == "averagePerceivedReadinessinBootcampAcrossCentersChart" ||
                      ctx.canvas.id == "averagePerceivedReadinessAcrossGendersChart"
                        ctx.fillStyle = "#000"
                        ctx.fillText(data.actualData.firstLabel[index] +
                            data.actualData.secondLabel[index] +
                            data.actualData.thirdLabel[index],
                            model.x + 15, model.y + 10)
        },
        legend: {
          display: false
        },
        responsive: true,
        hover: {
            animationDuration: 0
        },
        tooltips: @toolTipsOptions(chartName),
        layout:{
          padding:{
            left: 30,
            right: 70,
            bottom: 10,
            top: 10,
          }
        },
        scales: {
          pointLabels :{
            margin: 0
          }
          xAxes: [{
            stacked: stackColumns,
            gridLines: {
              display: false
            },
            ticks: @tickConfig(chartName),
            scaleLabel: @xLabels(chartName),
          }],
          yAxes: [{
            barThickness: axisThickness,
            stacked: stackColumns,
            scaleLabel: @yLabels(chartName),
            gridLines: {
              display: false
            },
            ticks: @tickConfig(chartName),
            barPercentage: 0.43,
            categoryPercentage: 0.9,
          }]
        },
        annotation: {
          events: ["mouseenter", "mouseleave"],
          annotations: @annotationConfig(chartName)
        },
      }
    })

  stackedVerticalBar:(chartName, canvasId, labels, data) ->
    stackedCanvas = document.getElementById(canvasId).getContext('2d')
    stackedCanvasBar = new Chart(stackedCanvas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: data.datasets
      },
      options:{
        legend: {
          display: true
          labels: @labelConfig()
        }
        responsive: true,
        scales:{
          yAxes: [{
            gridLines: {
              display: true,
            },
            ticks: {
              beginAtZero: true
              stepSize: 1
              fontSize: 10
            }
          }],
          xAxes: [{
            categoryPercentage: @categoryPercentageConfig(chartName),
            barPercentage: @barPercentageConfig(chartName),
            gridLines: {
              display: false,
            },
            ticks: @tickConfig(chartName)
          }]
        }
      }
    })

  labelConfig:() ->
    if $(window).width() >= 1281
      fontSize: 14
      fontColor: '#333E44'
      fontWeight: 'normal'
      boxWidth: 20
    else if $(window).width() < 1281
      fontSize: 9
      fontColor: '#333E44'
      fontWeight: 'normal'
      boxWidth: 20

  verticalBar:(chartName, canvasId, labels, data) ->
    verticalCanvas = document.getElementById(canvasId).getContext('2d')
    verticalBarChart = new Chart(verticalCanvas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: data.datasets
      },
      options: {
        tooltips: @toolTipsOptions(chartName),
        responsive: true,
        hover: {
          animationDuration: 0
        },
        legend: {
          display: false
        }
        animation: {
          duration: 0,
          onComplete: ->
            ctx = this.chart.ctx
            ctx.textAlign = 'center'
            ctx.textBaseline = 'bottom'
            ctx.font = 'normal 12px DINPro'
            for dataset in this.data.datasets
              for index, value of dataset.data
                for key, value of dataset._meta
                  model = dataset._meta[key].data[index]._model
                  if $(window).width() < 1281
                    ctx.fillText(data.actualData.firstLabel[index], model.x, model.y)
                  else
                    ctx.fillStyle = "#fff"
                    ctx.fillText(data.actualData.firstLabel[index], model.x, model.y + 18)
        },
        scales: {
          yAxes: [{
            gridLines: {
              display: true
            },
            ticks: {
              beginAtZero: true,
              padding: 8,
              stepSize: 1
              fontSize: 14
              min: 0,
              max: 10,
            }
          }]
          xAxes: [{
            categoryPercentage: 1.0,
            barPercentage: 0.8,
            gridLines: {
              display: false
            },
            ticks: {
              beginAtZero: true
              padding: 8
              fontSize: 14
              min: 0,
              stepSize: 1,
              max: 10,
            }
          }
          ]
        }
      }
      })

  barPercentageConfig:(chartName)->
    if chartName == "optionsDistributionMultipleChoiceBar" || "pictureMultipleChoiceBar"
      return 0.95
    else if chartName == "optionsDistributionCheckboxBar" || "pictureCheckboxBar"
      return 0.8

  categoryPercentageConfig:(chartName)->
    if chartName == "optionsDistributionMultipleChoiceBar" || "pictureMultipleChoiceBar"
      return 0.8
    else if chartName == "optionsDistributionCheckboxBar" || "pictureCheckboxBar"
      return 0.6

  tickConfig:(chartName) ->
    if chartName == "horizontalCenterAndGenderDistribution"
      {
        fontColor: '#303030',
        fontStyle: 'normal',
        fontfamily: 'DINPro',
        fontSize: '12',
        fontWeight: '300',
        min: 0,
        max: 100,
        stepSize: 5,
        callback: (value) ->
          if Math.floor(value) in [0, 25, 50, 65, 75, 100]
            return value
      }
    else if chartName == "optionsDistributionHorizontalBar"
      {
        fontStyle: 'normal',
        fontColor: '#333E44',
        fontfamily: 'DINPro',
        fontSize: '20',
        min: 0,
        max: 10,
        stepSize: 1,
      }
    else if chartName == "optionsDistributionMultipleChoiceBar" ||
            chartName == "pictureMultipleChoiceBar" ||
            chartName == "optionsDistributionCheckboxBar" || chartName == "pictureCheckboxBar"
      if $(window).width() >= 1281
        {
          fontColor: '#333E44',
          fontStyle: 'normal',
          fontfamily: 'DINPro',
          fontSize: '14',
          min: 0,
          max: 10,
          stepSize: 1,
        }
      else if $(window).height() == 1366 and $(window).width() == 1024
        fontStyle: 'normal',
        fontfamily: 'DINPro',
        fontColor: '#333E44',
        fontSize: '13',
        min: 0,
        max: 10,
        stepSize: 1,
      else
        fontStyle: 'normal',
        fontColor: '#333E44',
        fontfamily: 'DINPro',
        fontSize: '10',
        min: 0,
        max: 10,
        stepSize: 1,

    else
      {
        fontStyle: 'normal',
        fontfamily: 'DINPro',
        fontSize: '12',
        min: 0,
        max: 100,
        stepSize: 25,
      }

  annotationConfig: (chartName) ->
    annotations = [
      {
        type: 'line',
        drawTime: "beforeDatasetsDraw",
        mode: 'vertical',
        scaleID: 'x-axis-0',
        value: 25,
        borderColor: '#E1E1E1',
        borderWidth: 1,
      },
      {
        type: 'line',
        drawTime: "beforeDatasetsDraw",
        mode: 'vertical',
        scaleID: 'x-axis-0',
        value: 50,
        borderColor: '#E1E1E1',
        borderWidth: 1,
      },
      {
        type: 'line',
        drawTime: "beforeDatasetsDraw",
        mode: 'vertical',
        scaleID: 'x-axis-0',
        value: 75,
        borderColor: '#E1E1E1',
        borderWidth: 1,
      },
      {
        type: 'line',
        drawTime: "beforeDatasetsDraw",
        mode: 'vertical',
        scaleID: 'x-axis-0',
        value: 100,
        borderColor: '#E1E1E1',
        borderWidth: 1,
      }
    ]

    if chartName == "horizontalCenterAndGenderDistribution"
      annotations.push  {
        type: 'line',
        mode: 'vertical',
        scaleID: 'x-axis-0',
        value: 65,
        borderColor: '#fff',
        borderDash: [10, 10],
        borderWidth: 2,
        label: {
          fontFamily: 'DINPro',
          fontSize: '12',
          fontWeight: '300',
          content: "Female Target",
          enabled: true,
          position: "top",
          backgroundColor: '#fff',
          fontColor: "#303030",
          fontStyle: "normal",
          xPadding: 10,
        }
      }

    return annotations

  yLabels: (chartName) ->
    if chartName == "averagePerceivedReadinessAcrossCenters"
      {
        display: true,
        fontSize: 12,
        fontFamily: "DINPro-Light",
        padding: 5,
        labelString: "Perceived Readiness Evaluations",
      }
    else if chartName == "horizontalPerceivedReadinessAcrossGenders"
      {
        display: true,
        fontSize: 12,
        fontFamily: "DINPro-Light",
        padding: 10,
        labelString: "Perceived Readiness Evaluation",
      }
    else
      {
        display: false
      }

  xLabels: (chartName) ->
    if chartName == "lfaToLearnerRatio"
      display: true,
      labelString: "LFA to Learner Distribution %"
    else if chartName == "horizontalCenterAndGenderDistribution"
      display: true,
      labelString: "Gender Distribution %"
    else if chartName == "horizontalPerceivedReadinessAcrossGenders"
      display: false
    else if chartName == "averagePerceivedReadinessAcrossCenters"
      display: false
    else if chartName == "optionsDistibutionHorizontalBar"
      display: false

  mixedChart: (chartName, canvasId, labels, datasets) ->
    chartCanvas = document.getElementById(canvasId).getContext('2d')
    newMixedChart = new Chart(chartCanvas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: @mixedChartData(datasets)
      },
      options: {
        title: {
          display: false
        },
        tooltips: @toolTipsOptions(chartName),
        legend: {
          display: false,
          position: 'None',
        },
        scales: {
          xAxes: [{
            display: true,
            barPercentage: 1,
            categoryPercentage: 1,
            gridLines: {
              lineWidth: 0.7,
              tickMarkLength: 0,
              zeroLineWidth: 0,
            },
            ticks: {
              labelOffset: 0,
              fontColor: '#737373',
              fontFamily: "DINPro-Light",
              fontSize: 12,
              fontStyle: 'normal',
              padding: 10,
              maxRotation: 30,
              autoSkip: false
            },
            scaleLabel: @xAxisLabels(chartName)
          }],
          yAxes: [{
            display: true,
            gridLines: {
              lineWidth: 0.7,
              tickMarkLength: 0,
              zeroLineWidth: 0,
            },
            labelOffset: 100,
            ticks: {
              min: 0,
              stepSize: 5,
              fontColor: '#737373',
              fontFamily: "DINPro-Light",
              fontSize: 12,
              fontStyle: 'normal',
              padding: 6
            },
            scaleLabel: @yAxisLabels(chartName)
          }],
        },
      }
    })

  mixedChartData: (datasets) ->
    [
      {
      label: datasets[0].label,
      type: 'bar',
      data: datasets[0].data,
      backgroundColor: '#3359DB',
      borderWidth: 1,
      },
      {
      label: datasets[1].label,
      type: 'line',
      showLine: false,
      data: datasets[1].data,
      pointRadius: 0,
      pointHoverRadius: 0,
      },
      {
      label: datasets[2].label,
      type: 'line',
      showLine: false,
      data: datasets[2].data,
      pointRadius: 0,
      pointHoverRadius: 0,
      }
    ]
