class EditLearnerTechnicalDetails.UI
  constructor: ->
    @modal = new Modal.App("#edit-learner-technical-details-modal", 500, 500,
      "auto", "auto")
    @loaderUI = new Loader.UI()
    @savedLanguageStacks = []

  openEditLearnerTechnicalDetailsModal: (fetchLearnerTechnicalDetails) =>
    self = @
    $(".technical-details-btn, .technical-details-btn-mobile").click ->
      self.resetLearnerALCLanguagesStacks()
      self.modal.open()
      self.resetInput()
      self.modal.setHeaderTitle(".edit-learner-technical-details-header .title",
        "Edit Technical Details")
      $("body").css("overflow", "hidden")

      fetchLearnerTechnicalDetails()

  populateALCLanguagesStacks: (alcLanguagesStacks) =>
    self = @
    for alcLanguageStack in alcLanguagesStacks
      $(".learner-alc-languages-stacks").append(
        "<label class='input-container'>
          #{alcLanguageStack}
          <input type='checkbox' disabled checked>
          <span class='checkmark'></span>
        </label>"
      )
    
  resetInput: ->
    inputIds = $(".learner-preferred-languages-stacks label.input-container").length
    for inputId in [1..inputIds]
      $("##{inputId}")[0].checked = false

  populatePreferredLanguagesStacks: (preferredLanguagesStacks) =>
    self = @
    $(".preferred-stack-wrapper:first .stacks").html("")
    @savedLanguageStacks = []
    if preferredLanguagesStacks.length
      for preferredLanguageStack in preferredLanguagesStacks
        $("##{preferredLanguageStack[0]}")[0].checked = true
        $(".preferred-stack-wrapper:first .stacks").append(
          "<span>#{preferredLanguageStack[1]}<span>"
        )
        self.savedLanguageStacks.push(preferredLanguageStack[0])
      return
    
    $(".preferred-stack-wrapper:first .stacks").append(
        "<span>N/A<span>"
      )

  resetLearnerALCLanguagesStacks: ->
    $(".learner-alc-languages-stacks").html(
      "<label for='alc-languages-stacks-input' class='input-label'>
        Languages/Stacks
      </label>"
    )

  getUpdatedData: ->
    self = @
    preferredLanguagesStacks = []
    selectedLanguagesStacks =
      $("input[name=preferred_languages_stacks]:checked")

    for languageStack in [0...selectedLanguagesStacks.length]
      preferredLanguagesStacks.push (
        parseInt(selectedLanguagesStacks[languageStack].value, 10)
        )

    updatedData = {
      "preferred_languages_stacks": preferredLanguagesStacks
    }

    return updatedData

  submitLearnerTechnicalDetails: (updateLearnerTechnicalDetails) ->
    self = @
    $(".save-edit-learner-technical-details").click (event) ->
      $("#edit-learner-technical-details-form").validate()
      event.preventDefault()
      updatedData = self.getUpdatedData()

      if "#{self.savedLanguageStacks}" is "#{updatedData["preferred_languages_stacks"]}"
        self.showToastNotification("No change has been made", "success")
        return

      if $("#edit-learner-technical-details-form").valid()
        self.loaderUI.show()
        updateLearnerTechnicalDetails(updatedData)
        $("body").css("overflow", "auto")

  showToastNotification: (message, status) ->
    $('.toast').messageToast.start(message, status)

  closeEditLearnerTechnicalDetailsModal: =>
    self = @
    $(".close-button").click ->
      self.modal.close()
      $("body").css("overflow", "auto")

  initializeEditLearnerTechnicalDetails: (
    fetchLearnerTechnicalDetails
    ) =>
    @openEditLearnerTechnicalDetailsModal(fetchLearnerTechnicalDetails)
    @closeEditLearnerTechnicalDetailsModal()
