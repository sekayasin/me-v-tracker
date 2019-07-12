class SurveyTableTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new SurveyTableTour.UI(@api)

  start: ->
    @ui.initSurveyTableTour()
