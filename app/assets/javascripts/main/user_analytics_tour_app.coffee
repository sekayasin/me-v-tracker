class UserAnalyticsTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new UserAnalyticsTour.UI(@api)

  start: ->
    @ui.waitForLoadingScreen()
