class EditLearnerProgramsTour.APP
  constructor: ->
    @api = new Tour.API()
    @ui = new EditLearnerProgramsTour.UI(@api)

  start: ->
    @ui.initEditLearnerProgramsTour()
