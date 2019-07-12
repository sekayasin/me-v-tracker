class ProgramFeedbackChart.App
  constructor: ->
    @ui = new ProgramFeedbackChart.UI()
    @api = new ProgramFeedbackChart.API()

  initializeCharts: =>
    @ui.populateDropdowns(@api.fetchProgramFeedbackCenters, @api.getProgramFeedback)
    @ui.onPanelActive(@api.getProgramFeedback)
