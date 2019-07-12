class LearningEcosystem.App
  constructor: ->
    @api = new LearningEcosystem.API()
    @ui = new LearningEcosystem.UI(
      @api.fetchPhases,
      @api.fetchOutput,
      @api.submitOutput,
      @api.updateOutput
    )

  start: ->
    @ui.initializeTabs('overview-bar')
    @ui.initializeMultipleOutputSubmissionModalTabs('multiple-output-bar')
    @ui.initializeAccordions()
