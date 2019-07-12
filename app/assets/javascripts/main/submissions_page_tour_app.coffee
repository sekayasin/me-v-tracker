class SubmissionsPageTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new SubmissionsPageTour.UI(@api)

  start: ->
    @ui.initSubmissionsPageTour()
