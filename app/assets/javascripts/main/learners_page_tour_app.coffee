class LearnersPageTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new LearnersPageTour.UI(@api)

  start: ->
    @ui.initLearnersPageTour()
