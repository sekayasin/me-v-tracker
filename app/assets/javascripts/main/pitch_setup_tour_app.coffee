class Pitch.PitchSetupTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Pitch.PitchSetupTour.UI(@api)

   start: ->
    @ui.initPitchSetupTour()
