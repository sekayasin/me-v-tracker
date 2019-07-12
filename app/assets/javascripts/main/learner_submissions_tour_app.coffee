class LearnerSubmissionsTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new LearnerSubmissionsTour.UI(@api)

  start: ->
    @ui.initLearnerSubmissionsTour()
