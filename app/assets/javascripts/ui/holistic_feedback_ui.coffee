class HolisticFeedback.UI
  constructor: ->
    @holisticFeedbackModal = new Modal.App("#holistic-feedback-modal", 900, 900, 700, 700)
    @loaderUI = new Loader.UI()

  openHolisticFeedbackModal: =>
    self = @
    $(".holistic-feedback-btn").on "click", (event) ->
      self.holisticFeedbackModal.open()
      $("#learner-feedback-modal").hide()

  closeHolisticFeedbackModal: =>
    self = @
    $(".close-holistic-feedback-modal").on "click", (event) ->
      self.holisticFeedbackModal.close()
      self.clearFormFields()
      $("#learner-feedback-modal").show()

  clearFormFields: =>
    $("#holistic-feedback-form").find("textarea").map ->
      $(this).val ''
      $(".feedback-error").html ''

  saveHolisticFeedbackDetails: (saveHolisticFeedback, holisticFeedback) =>
    self = @
    saveHolisticFeedback(holisticFeedback)
      .then ->
        self.toastMessage('Holistic Feedback saved successfully', 'success')
        $("#learner-feedback-modal").show()
        self.holisticFeedbackModal.close()
        self.clearFormFields()

  submitHolisticFeedback: (saveHolisticFeedback) =>
    self = @
    self.holisticFeedback = []
    $(".holistic-feedback-button").on "click", (event) ->
      event.stopImmediatePropagation()

      if $("#holistic-feedback-form").valid()
        self.loaderUI.show()
        $("#holistic-feedback-form").find("textarea").map ->
          criteriumId = $(this).attr('id')
          comment = $(this).val()
          self.holisticFeedback.push({ criterium_id: criteriumId, comment: comment })

        self.saveHolisticFeedbackDetails(saveHolisticFeedback, self.holisticFeedback)

  validateFormFields: =>
    $.validator.addMethod 'requireNotBlank', ((value, element) ->
      $.validator.methods.required.call this, $.trim(value), element
    ), $.validator.messages.required

    $("#holistic-feedback-form").validate
      rules:
        quality: "required requireNotBlank"
        integration: "required requireNotBlank"
        epic: "required requireNotBlank"
        quantity: "required requireNotBlank"
        initiative: "required requireNotBlank"
        communication: "required requireNotBlank"
        learning: "required requireNotBlank"

      messages:
        quality: "Comment is required"
        integration: "Comment is required"
        epic: "Comment is required"
        quantity: "Comment is required"
        initiative: "Comment is required"
        communication: "Comment is required"
        learning: "Comment is required"

      errorPlacement: (error, element) ->
        switch
          when element.attr("name") == "quality" then $("#quality_error").html error
          when element.attr("name") == "integration" then $("#integration_error").html error
          when element.attr("name") == "epic" then $("#epic_error").html error
          when element.attr("name") == "quantity" then $("#quantity_error").html error
          when element.attr("name") == "initiative" then $("#initiative_error").html error
          when element.attr("name") == "communication" then $("#communication_error").html error
          when element.attr("name") == "learning" then $("#learning_error").html error

  toastMessage: (message, status) =>
    self = @
    self.loaderUI.hide()
    $(".toast").messageToast.start(message, status)

  initializeHolisticFeedback: (saveHolisticFeedback) =>
    @openHolisticFeedbackModal()
    @closeHolisticFeedbackModal()
    @submitHolisticFeedback(saveHolisticFeedback)
    @validateFormFields()
