class FeedbackText.App
  constructor: ->
    @ui = new FeedbackText.UI()

  start: =>
    @ui.handleFeedbackText()
