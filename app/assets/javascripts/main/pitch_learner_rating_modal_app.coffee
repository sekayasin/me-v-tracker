class Pitch.LearnerRatingModal.App
  constructor: ->
    @api = new Pitch.API()
    @ui = new Pitch.LearnerRatingModal.UI(@api)
  start: ->
    @ui.initialiseModal()
    