class Dashboard.App
  constructor: ->
    @cycleMetricsCharts = new CycleMetricsChart.App()
    @programMetricsCharts = new ProgramMetricsChart.App()
    @programFeedbackCharts = new ProgramFeedbackChart.App()

  start: =>
    @cycleMetricsCharts.initializeCharts()
    @programMetricsCharts.initializeCharts()
    @programFeedbackCharts.initializeCharts()
