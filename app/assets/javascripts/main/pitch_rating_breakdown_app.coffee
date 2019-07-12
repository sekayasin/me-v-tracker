class Pitch.PitchRatingBreakdown.App
  constructor: ->
    @api = new Pitch.API()
    @ui = new Pitch.PitchRatingBreakdown.UI(@api)

   start: =>
    @ui.initialize()
