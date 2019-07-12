class Pitch.PitchRateLearnerTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new Pitch.PitchRateLearnerTour.UI(@api)

  start: ->
    @ui.initPitchRateLearnerTour()
