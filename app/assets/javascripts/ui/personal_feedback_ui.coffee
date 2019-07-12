class PersonalFeedback.UI
  constructor: () ->
    @modal = new Modal.App('#personal-feedback-modal', 960, 520, 605, 700)
    @learnerProgramId = location.pathname.split("/")[3]
    @criteria = []
    @impressionText = "Select Feedback Impression"
    @outputText = "Select Output"
    @personalFeedback = {}

  openPersonalFeedbackModal: =>
    action = new $.Deferred()
    self = @
    mainBody = $(document)
    pageWidth = mainBody.width()
    $('.personal-feedback-btn').click ->
      self.modal.open()
      self.pageScroll("hidden")
      $('body').css("overflow", "hidden")
      action.resolve('done')

    $('.close-personal-feedback-modal').click ->
      self.modal.close()
      self.pageScroll("hidden")
      $('#learner-feedback-modal').css("display", "block")
      if pageWidth <= 890
        mainBody.scrollTop(0)

    $('.cancel-feedback-modal').click ->
      self.modal.close()
      self.resetModal()
      self.pageScroll("hidden")
      $('#learner-feedback-modal').css("display", "block")
    return action

  selectPhaseChanged: (callback) =>
    self = @
    $('#learner-phase').on 'selectmenuchange', () ->
      callback.call().then (response) =>
        self.frameworkCriteriaChangeEvents(response)

  selectOutputImpressionChanged: (callback) =>
    $('#learner-output').on 'selectmenuchange', () ->
      callback.call()
      $('#learner-output-error').css("display", "none")

    $('#learner-impression').on 'selectmenuchange', () ->
      $('#learner-impression-error').css("visibility", "hidden")

  frameworkCriteriaChangeEvents: (assessments) =>
    self = @
    $('#learner-framework').on 'selectmenuchange', () ->
      self.populateCriteriaDropdown('#learner-framework', assessments)
      self.populateOutputDropdown()

    $('#learner-criteria').on 'selectmenuchange', () ->
      self.populateOutputDropdown()

  getPersonalFeedbackDetails: (feedbackDetails) ->
    self = @
    if feedbackDetails isnt null
      $('#comment-box').val feedbackDetails.comment
      $('#comment-box').focus()
      selectedOption = feedbackDetails.impression_id
      $('#learner-impression').val("#{selectedOption}").selectmenu('refresh')
    else
      $('#learner-impression').val('').selectmenu('refresh')
      $('#comment-box').val('')

  populateDropdown: (elementId, data, optionHeader="") =>
    $(elementId).html ''
    options = ""
    if optionHeader.length > 1
      options = "<option value='' name='default' selected disabled> #{optionHeader} </option>"

    for key, selectOption of data
      options += "<option value='#{selectOption.id}'>#{selectOption.name}</option>"

    @generateDropdown $(elementId), options

  populateFrameworkDropdown: (elementId, data) =>
    $(elementId).html ''
    options = ""
    for selectOption of data
      options += "<option value='#{selectOption}'>#{selectOption}</option>"

    @generateDropdown $(elementId), options

  populateCriteriaDropdown: (elementId, data) =>
    framework = $(elementId).val()
    @criteria = data[framework]
    @populateFrameworkDropdown '#learner-criteria', @criteria

  populateOutputDropdown: =>
    criteria = $('#learner-criteria').val()
    @populateDropdown '#learner-output', @criteria[criteria], @outputText

  getPersonalFeedback: =>
    phase = $('#learner-phase').val()
    output = $('#learner-output').val()
    {
      learner_program_id: @learnerProgramId
      phase_id: phase
      assessment_id: output
    }

  submitPersonalFeedback: (validateFields) =>
    self = @

    $('#personal-feedback-form').submit (event) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      impression = event.target.impression.value
      comment = event.target.comment.value
      personalFeedback = self.getPersonalFeedback()

      personalFeedback = $.extend({}, personalFeedback, {
        impression_id: impression
        comment: comment,
        finalized: true
      })
      validateFields(personalFeedback)

  revealToast: (message, status) =>
    $('.toast').messageToast.start(message, status)

  generateDropdown: (selectElement, selectOptions) =>
    selectElement.html ''
    selectElement.append selectOptions
    selectElement.selectmenu "refresh"

  resetModal: =>
    $('#learner-phase').val('1')
    $("#learner-phase").selectmenu "refresh"
    $('#learner-output').selectmenu "refresh"
    $('#learner-impression').selectmenu "refresh"
    $('#comment-box').val('')

  pageScroll: (style) =>
    $('body').css('overflow', style)

  validateOutputImpression: (personalFeedback) =>
    if personalFeedback.assessment_id is null
      $('#learner-output-error').css("display", "block")
    else $('#learner-output-error').css("display", "none")

    if personalFeedback.impression_id < 1
      $('#learner-impression-error').css("visibility", "visible")
    else $('#learner-impression-error').css("visibility", "hidden")
