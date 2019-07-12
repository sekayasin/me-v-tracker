class LearnerFeedback.App
  constructor: ->
    @ui = new LearnerFeedback.UI()

  start: =>
    @ui.openLearnerFeedbackModal()

