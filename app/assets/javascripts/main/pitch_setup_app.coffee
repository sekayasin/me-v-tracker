class Pitch.PitchSetup.App
  constructor: ->
    @api = new Pitch.API()
    @ui = new Pitch.PitchSetup.UI(@api)

  start: =>
    @ui.initialize()

  update: (pitch_id) =>
    @ui.update(pitch_id)
