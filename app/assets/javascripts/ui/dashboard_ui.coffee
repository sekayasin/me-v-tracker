class Dashboard.UI
  constructor: ->
    @chartUI = new ChartJs.UI()

  genderDistributionData: (canvasId, data, totals) ->
    chartName = 'gender'
    labels = ['Male              ', 'Female           ']
    colors = ['#3359db', '#ffaf30']
    rotation = -0.5

    @chartUI.pieChart(chartName, canvasId, labels, data, colors, rotation, totals)

  lfaToLearnersRatioData: (canvasId, actual, target) ->
    chartName = 'lfaToLearnersRatio'
    labels = ['LFA to Learners Ratio']
    datasets = [
      {
        label: 'Actual',
        backgroundColor: "#3359DB",
        data: actual
      }
      {
        label: 'Target',
        backgroundColor: '#FFAF30',
        data: target
      }
    ]
    config =
      min: 0
      max: 100
      stepSize: 25
      displayLabel: false
      showLegend: false

    @chartUI.barChart(chartName, canvasId, labels, datasets, config)

  lfaEvaluationVarianceData: (canvasId, actual, target) ->
    chartName = 'lfaEvaluationVariance'
    labels = ['LFA Evaluation Variance']
    datasets = [
      {
        label: 'Actual',
        backgroundColor: "#3359DB",
        data: actual
      }
      {
        label: 'Target',
        backgroundColor: '#FFAF30',
        data: target
      }
    ]
    config =
      min: 0
      max: 100
      stepSize: 25
      displayLabel: false
      showLegend: true
      position: 'right'

    @chartUI.barChart(chartName, canvasId, labels, datasets, config)

  outputExpectationsAverageData: (canvasId, actual, target) ->
    chartName = 'outputExpectationsAverage'
    labels = ['Output Expectations Average']
    datasets = [
      {
        label: 'Actual',
        backgroundColor: "#3359DB",
        data: actual
      }
      {
        label: 'Target',
        backgroundColor: '#FFAF30',
        data: target
      }
    ]
    config =
      min: -3
      max: 3
      stepSize: 1
      displayLabel: false
      showLegend: false

    @chartUI.barChart(chartName, canvasId, labels, datasets, config)

  # Desktop rendering for holistic performance and dev framework
  holisticPerformanceDevFrameworkAverageData: (canvasId, actual, target) ->
    chartName = 'holisticPerformanceDevFramework'
    labels = ['Holistic Performance Average', 'Developer Framework Average']
    datasets = [
      {
        label: 'Actual',
        backgroundColor: "#3359DB",
        data: actual
      }
      {
        label: 'Target',
        backgroundColor: '#FFAF30',
        data: target
      }
    ]
    config =
      min: -2
      max: 2
      stepSize: 1
      displayLabel: false
      showLegend: false

    @chartUI.barChart(chartName, canvasId, labels, datasets, config)

  # Mobile rendering for developer framework average
  developerFrameworkAverageData: (canvasId, actual, target) ->
    chartName = 'developerFrameworkAverage'
    labels = ['Developer Framework Average']
    datasets = [
      {
        label: 'Actual',
        backgroundColor: "#3359DB",
        data: actual
      }
      {
        label: 'Target',
        backgroundColor: '#FFAF30',
        data: target
      }
    ]
    config =
      min: -2
      max: 2
      stepSize: 1
      displayLabel: false
      showLegend: false

    @chartUI.barChart(chartName, canvasId, labels, datasets, config)

  holisticPerformanceAverageData: (canvasId, actual, target) ->
    chartName = 'holisticPerformanceAverage'
    labels = ['Holistic Performance Average']
    datasets = [
      {
        label: 'Actual',
        backgroundColor: "#3359DB",
        data: actual
      }
      {
        label: 'Target',
        backgroundColor: '#FFAF30',
        data: target
      }
    ]
    config =
      min: -2
      max: 2
      stepSize: 1
      displayLabel: false
      showLegend: false

    @chartUI.barChart(chartName, canvasId, labels, datasets, config)

  redrawChart: (canvasId, canvasHeight, hasBarChartWrapper = false) ->
    html = """<canvas id="#{canvasId}" height="#{canvasHeight}px"></canvas>"""
    if hasBarChartWrapper
      html = "<div class='barchart-wrapper'>#{html}</div>"

    $("##{canvasId}Container").empty().append(html)
