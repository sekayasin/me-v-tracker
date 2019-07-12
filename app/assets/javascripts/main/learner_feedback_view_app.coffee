class LearnerFeedbackView.App
  constructor: ->
    @api = new LearnerFeedbackView.API()
    @ui = new LearnerFeedbackView.UI(
      @api.fetchFeedback,
      @api.submitReflection,
      @api.fetchReflection,
      @api.updateReflection
    )

  start: =>
    @ui.openFeedbackViewModal()
