class Pitch.PitchPageTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Pitch.PitchPageTour.UI(@api)

   start: ->
    @ui.initPitchPageTour()
