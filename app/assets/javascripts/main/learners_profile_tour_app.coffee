class LearnerProfileTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new LearnerProfileTour.UI(@api)

  start: ->
    @ui.initLearnersProfileTour()
