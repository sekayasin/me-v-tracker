class HolisticEvaluations.UI
  constructor: ->
    @modal = new Modal.App('#holistic-performance-evaluation', 865, 865, 'auto', 'auto')
    @confirmationModal = new Modal.App('#confirmation-modal', 500, 500, 255, 255)
    @evaluationLimitModal = new Modal.App('#evaluation-limit-modal', 500, 500, 300, 300)
    @loaderUI = new Loader.UI()
    @blank = ''
    @holisticEvaluation = []
    @criteriaLength = $('#evaluation-form').find('input.hidden-length').val()

  clearForm: =>
    $('div.criterium-card').find('textarea').val("")
    $('div.criterium-card').find('select').val("")
    $('.satisfaction-level').selectmenu('refresh')

  togglePageScroll: (style) =>
    $('body').css('overflow', style)

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)

  setAverages: (data) ->
    $.each data, (criteria, score) ->
      criteria = criteria.split(" ")[0]
      criterium_card = $('.criterium-wrapper').find('.'+ criteria)

      if criterium_card
        $(criterium_card).find('.holistic-average').text("AVG: " + score)

  checkAdminLfaAccess: () ->
    if $(".user-notice").length > 0
      $(".leave-comment, .satisfaction-level").attr('disabled', 'disabled')
      $("#confirm-submission").hide()

  handleOpenHolisticModal: (fetchAverages, getEvaluationEligibility) =>
    self = @
    $('.holistic-evaluation-btn').click ->
      window.scrollTo(0, 0)
      fetchAverages().then (data) ->
        self.setAverages(data)

      if $("#confirm-submission").attr("disabled") == "disabled"
        self.openEvaluationLimitModal()
      else
        self.canEvaluate(getEvaluationEligibility)

  openHolisticModal: ->
    self = @
    $('#edit-learner-bio-info-modal').hide()
    self.modal.open()
    self.togglePageScroll('hidden')
    $('.close-modal').click ->
      self.modal.close()
      self.togglePageScroll('auto')
      self.clearForm()

  openEvaluationLimitModal: =>
    self = @
    self.evaluationLimitModal.open()
    $("#evaluation-limit-warning-modal").click (event) ->
      event.stopPropagation()
      self.evaluationLimitModal.close()
      self.disableHolisticModal()
      self.openHolisticModal()

  getHolisticEvaluationDetails: (validateFields) =>
    self = @
    self.holisticEvaluation = []
    self.errors = []

    $('#evaluation-form > div.criterium-wrapper > div.criterium-card').each () ->
      criteriumId = $(this).find('.criterium-header').find('span').attr('id')
      comment = $(this).find('textarea').val()
      score = $(this).find('select').val()

      checkSpaces = $.trim(comment).length == 0
      evaluationData = {
        criteriumId,
        comment,
        score
      }
      self.blank = validateFields(evaluationData, checkSpaces)
      if self.blank == ''
        self.holisticEvaluation.push({ criterium_id: criteriumId, score: score, comment: comment })
      else
        self.errors.push(self.blank)

  submitHolisticEvaluationDetails: (validateFields) =>
    self = @
    $('#evaluation-form').submit (event) ->
      event.preventDefault()
      self.getHolisticEvaluationDetails(validateFields)
      self.checkBlankFields()

  confirmSubmission: ->
    self = @
    $('#holistic-performance-evaluation').css('display', 'none')
    self.confirmationModal.open()

  cancelSubmission: ->
    self = @
    $('div#confirmation-modal').find('a.btn-cancel, .btn-cancel').click (event) ->
      self.confirmationModal.close()
      $('#holistic-performance-evaluation').css('display', 'block')

  checkBlankFields: =>
    self = @
    if self.errors[self.errors.length-1]
      self.flashErrorMessage(self.errors[self.errors.length-1])
      self.errors = []
    else
      $('.ui-dialog').css('padding', 0)
      self.confirmSubmission()
      self.cancelSubmission()

  flashErrorMessage: (@blank) =>
    self = @
    if self.blank is 'no score'
      self.toastMessage('Please select a Satisfaction Level for all fields', 'error')
    else if self.blank is 'no comment'
      self.toastMessage(
        'Please add valid comments to all mandatory fields', 'error')

  disableHolisticModal: ->
    $("#confirm-submission").attr("disabled", "disabled")
    $("#confirm-submission").addClass("disabled")
    $("#evaluation-form .criterium-card .leave-comment").attr("disabled", "disabled")
    $("#evaluation-form .criterium-card .leave-comment").addClass("disabled")
    $(".select-background>span").addClass("disabled")
    $(".satisfaction-level").off()
    $("#evaluation-form .ui-selectmenu-button").off()

  canEvaluate: (getEvaluationEligibility) =>
    self = @
    getEvaluationEligibility().then (data) ->
      if data["eligible"]
        self.openHolisticModal()
      else
        self.openEvaluationLimitModal()

  clickSubmitBtn: (saveHolisticEvaluation) ->
    self = @
    $('#confirm-evaluation-submission').click ->
      self.loaderUI.show()

      saveHolisticEvaluation(self.holisticEvaluation).then (data)->
        self.loaderUI.hide()
        self.toastMessage('Holistic evaluation successfully saved', 'success')
        self.confirmationModal.close()
        self.clearForm()
        self.modal.close()
        self.togglePageScroll('auto')
        self.setReceivedEvaluations(data["evaluations_received"])
        if data["eligible"] == false
          self.disableHolisticModal()
          self.toastMessage('You have completed all required evaluations for this learner', 'warning')

  setReceivedEvaluations: (evaluationsReceived) ->
    self = @
    holisticEvaluationsElement = $("#holistic_evaluations_received")
    holisticEvaluationsElement.text(evaluationsReceived)
