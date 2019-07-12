class SurveyBuilderTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new SurveyBuilderTour.UI(@api)

  start: ->
    @ui.initSurveyBuilderTour()
