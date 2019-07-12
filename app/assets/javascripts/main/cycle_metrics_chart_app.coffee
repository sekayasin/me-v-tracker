class CycleMetricsChart.App
  constructor: ->
    @ui = new CycleMetricsChart.UI()
    @api = new CycleMetricsChart.API()
    @programId = localStorage.getItem('programId')

  fetchCenterCyclesData: (center) =>
    return @api.fetchCenterCyclesData(@programId, center)

  initializeCharts: =>
    @ui.visualizeDataCharts(@fetchCenterCyclesData)
    @ui.centerDropdownOnChange(@fetchCenterCyclesData)
    @ui.onPanelActive(@fetchCenterCyclesData, @ui.getChartMetrics)
    @ui.cycleDropdownOnChange()
    @ui.genderDropdownOnChange()
    @ui.handleResizing()
    @ui.downloadReport(@programId)
