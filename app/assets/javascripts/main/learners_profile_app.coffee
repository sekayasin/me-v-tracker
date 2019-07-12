class LearnersProfile.App
  constructor: ->
    @ui = new LearnersProfile.UI()
    @api = new LearnersProfile.API()

  start: ->
    @ui.initializeEditPersonalDetails()
    @ui.bindUpdateBtnToClick(@api.updatePersonalDetails)
