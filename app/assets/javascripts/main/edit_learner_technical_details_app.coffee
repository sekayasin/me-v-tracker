class EditLearnerTechnicalDetails.App
  constructor: ->
    @editLearnerTechnicalDetailsUI = new EditLearnerTechnicalDetails.UI()
    @editLearnerTechnicalDetailsAPI = new EditLearnerTechnicalDetails.API()

  start: =>
    @editLearnerTechnicalDetailsUI.initializeEditLearnerTechnicalDetails(
      @fetchLearnerTechnicalDetails
      )
    @editLearnerTechnicalDetailsUI.submitLearnerTechnicalDetails(
      @updateLearnerTechnicalDetails
      )

  fetchLearnerTechnicalDetails: =>
    self = @
    self.editLearnerTechnicalDetailsAPI.fetchLearnerTechnicalDetails()
    .then (data) ->
      self.editLearnerTechnicalDetailsUI.populateALCLanguagesStacks(
        data["alc_languages_stacks"]
        )
      self.editLearnerTechnicalDetailsUI.populatePreferredLanguagesStacks(
        data["preferred_languages_stacks"]
        )

  updateLearnerTechnicalDetails: (details) =>
    self = @
    self.editLearnerTechnicalDetailsAPI.updateLearnerTechnicalDetails(details)
    .then (response) ->
      if !response.error
        self.editLearnerTechnicalDetailsUI.populatePreferredLanguagesStacks(
          response.preferred_languages_stacks
        )
        self.editLearnerTechnicalDetailsUI.showToastNotification(
          response.message, "success"
        )
        self.editLearnerTechnicalDetailsUI.modal.close()
        self.editLearnerTechnicalDetailsUI.loaderUI.hide()
      else
        self.editLearnerTechnicalDetailsUI.showToastNotification(
          response.message, "error"
        )
        self.editLearnerTechnicalDetailsUI.loaderUI.hide()
