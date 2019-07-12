class EditLearnerBioInfo.App
  constructor: ->
    @api = new EditLearnerBioInfo.API()
    @ui = new EditLearnerBioInfo.UI()
    
  start: =>
    @ui.initializeEditLearnerBioInfo(@api.learnerInfo, @api.getLearnerCity)
