class Pitch.PitchLearnerSubmission.App
  constructor: ->
    @api = new Pitch.API()
    @ui = new Pitch.PitchLearnerSubmission.UI(@api)

  start: =>
    @ui.initialize()
