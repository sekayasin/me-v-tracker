class ProgramsPageTour.APP
  constructor: ->
    @api = new Tour.API()
    @ui = new ProgramsPageTour.UI(@api)

  start: ->
    @ui.initProgramsPageTour()
