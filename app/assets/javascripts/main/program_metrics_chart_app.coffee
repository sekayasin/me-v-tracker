class ProgramMetricsChart.App
  constructor: ->
    @ui = new ProgramMetricsChart.UI()
    @programMetricsAPI = new ProgramMetricsChart.API()
    @activeTabId
    @programId = localStorage.getItem("programId")
  
  fetchProgramMetricsData: (startDate, endDate) =>
    return @programMetricsAPI.getProgramMetrics(@programId, startDate, endDate)
 
  initializeCharts: =>
    @ui.loadCharts(@fetchProgramMetricsData)
    @ui.handleDateSelection(@fetchProgramMetricsData)
    @ui.handleResizing()
    @ui.downloadReport(@activeTabId)
