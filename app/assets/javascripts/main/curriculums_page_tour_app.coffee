class CurriculumsPageTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new CurriculumsPageTour.UI(@api)

  start: ->
    @ui.initCurriculumsPageTour()
