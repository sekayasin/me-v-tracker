class LearnersProfileTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new LearnersProfileTour.UI(@api)

   start: ->
    @ui.initLearnerProfileTour()
