class LearnerScore.UI
  constructor: ->
    @scoresURL = window.location.href + '.json'
    @assessments = {}
    @submittedScores = {}
    @jqueryDropdownUi = new JqueryDropdown.UI({
      selectDropdownClass: 'assessment-rating'
    })
    @profileUI = new Profile.UI()
    @outputInfoModal = new Modal.App('#output-info-modal', 545, 545, 650, 650)
    @loaderUI = new Loader.UI()
    @getOutputMetrics
    @evaluationLimitModal = new Modal.App('#evaluation-limit-modal', 'auto', 'auto', 'auto', 'auto')
    @holisticFeedbackModal = new Modal.App("#holistic-feedback-modal", 'auto', 'auto', 'auto', 'auto')
    @decisionModal = new Modal.App('#modal', 525, 525, 525, 525)
    @dropdownDecision = new Modal.App('#decision-select')
    @dropdownDecisionReason = new Modal.App('#decision-reason')
    @originalOption = ''
    @secondDecisionOption = ''
    @stage = ''
    @learnerDashboard = new LearnersDashboard.UI()


  loadPhaseAssessments: (getAssessments) =>
    self = @
    phaseId = @getSelectedPhaseId()
    $('#submit-score').addClass('inactive-submit-btn')

    getAssessments("/phases/#{phaseId}/assessment").then((assessments) ->
      $('#submit-score').removeClass('inactive-submit-btn')
      self.assessments = assessments
      self.generateFrameworkDropdown(assessments)
      self.generateCriteriumDropdown(assessments)
      self.generateScoreForm(assessments)
      self.updateSelectionLabel()
      self.removeCheckMarkOnSelect()
    )

  loadSubmittedScores: (getSubmittedScores) =>
    getSubmittedScores().then((scores) ->
      self.submittedScores = scores
    )

  initializeDecisionModal: (getDecisionReason, getDecisionDetail) =>
    self = @
    self.originalOption = $('select[name="decision-one"]').find('option:selected').text()
    self.secondDecisionOption = $('select[name="decision-two"]').find('option:selected').text()
    $('.profile-decision-dropdown').on "selectmenuchange", ->
      self.stage = $(this).data("stage")
      learnerProgramId = pageUrl[3]
      learnerDecisionStatus = $(this).val()
      self.learnerDashboard.updateCommentValue("textarea#decision-comment", "")
      self.populateDecisionReason(learnerDecisionStatus, getDecisionReason)
      self.populateDecisionComment(self.stage, learnerProgramId, getDecisionDetail)
      self.decisionModal.open()
      $('#decision-selects').val(learnerDecisionStatus)
      $('#decision-selects').selectmenu("refresh")
    $('#decision-selects').on 'selectmenuchange', (event) ->
      learnerDecisionStatus = $('#decision-selects').val()
      $("#decision-#{self.stage}").val(learnerDecisionStatus)
      $("#decision-#{self.stage}").selectmenu("refresh")
      self.populateDecisionReason(learnerDecisionStatus, getDecisionReason)
    $('#decision-cancel, .close-button, .ui-widget-overlay').click ->
      self.decisionModal.close()
      $('select[name="decision-one"]').val(self.originalOption)
      $('#decision-one').selectmenu("refresh")

      $('select[name="decision-two"]').val(self.secondDecisionOption)
      $('#decision-two').selectmenu("refresh")
      document.activeElement.blur()

  closeDecisionUpdateModal: =>
    @decisionModal.close()

  populateDecisionReason: (status, getDecisionReason) =>
    self = @
    if status != "In Progress"
      getDecisionReason(status).then(
        (decisionReasons) ->
          if decisionReasons
            options = "<option selected='selected'>Select Reasons</option>"
            $.each(decisionReasons, (index, decisionReason) =>
              options += "<option value='#{decisionReason}'>#{decisionReason}</option>"
            )
            self.learnerDashboard.toggleActiveDropdown('#decision-reason-select', options, 'disable')
            self.learnerDashboard.dropdownToggleIcon('decision-reason')
          else
            options = "<option selected='selected'>N/A</option>"
            self.learnerDashboard.toggleActiveDropdown('#decision-reason-select', options, 'enable')
      )
    else
      options = "<option selected='selected'>N/A</option>"
      self.learnerDashboard.toggleActiveDropdown('#decision-reason-select', options, 'enable')

  populateDecisionComment: (stage = "one", learnerProgramId, getDecisionDetail, updateCommentValue = false) =>
    self = @
    decisionStage = if stage == 'two' then 2 else 1
    getDecisionDetail(learnerProgramId).then(
      (response) ->
        if response.length > 0
          $.each(response, (index, recordedReason) ->
            if decisionStage is recordedReason.stage
              if recordedReason.details['Comment']
                $('textarea#decision-comment').val(recordedReason.details['Comment'])
              self.learnerDashboard.highlightDecisionReason('select.decision-reason-select option', recordedReason)
          )
      (error) ->
        self.learnerDashboard.updateCommentValue('textarea#decision-comment', "")
    )

  handleOnClickSaveDecision: (saveLearnersDecisionDetails) =>
    self = @
    $('.decision-button #decision-save').on 'click', (event) ->
      active = $('select[name="decision-selects"]')
      decisionStatusElementVal = active.val()
      learnerProgramDetail = $(".stage-learner-id").attr("id")
      learnerProgramId = pageUrl[3]
      learnerDecisionStatus = $('#decision-selects').val()
      learnerDecisionReasons = $('#decision-reason-select').val()
      learnerDecisionComment = $('.comment .leave-comment').val()

      decisionStage = if self.stage == 'two' then 2 else 1
      if decisionStage == 1
        status = { decision_one: learnerDecisionStatus.trim() }
      else
        status = { decision_two: learnerDecisionStatus.trim() }

      decisionData = {
        decisions: {
          stage: decisionStage,
          learner_program_id: learnerProgramId,
          reasons: learnerDecisionReasons,
          comment: learnerDecisionComment
        }
      }
      return unless self.checkDecisionStatus(learnerDecisionStatus) && self.checkDecisionReasons(decisionData)
      saveLearnersDecisionDetails(
        learnerDecisionStatus,
        status,
        learnerProgramId,
        decisionData,
        decisionStatusElementVal
      ).then (complete) =>
          self.originalOption = $('select[name="decision-one"]').find('option:selected').text()
          self.secondDecisionOption = $('select[name="decision-two"]').find('option:selected').text()
          document.activeElement.blur()

  checkDecisionStatus: (learnerDecisionStatus) ->
    unless learnerDecisionStatus == "In Progress"
      @learnerDashboard.clearErrorText("#decision-status-error")
      return true
    @learnerDashboard.displayErrorText("#decision-status-error", "Select a Decision")
    false

  checkDecisionReasons: (decisionData) ->
    unless decisionData.decisions.reasons.includes('Select Reasons')
      @learnerDashboard.clearErrorText("#decision-reason-error")
      return true
    @learnerDashboard.displayErrorText("#decision-reason-error", "Select Valid Reasons")
    false

  handleOnPageLoad: (getAssessments, getSubmittedScores, getOutputMetrics) =>
    self = @
    self.evaluationLimitModal.close()
    self.holisticFeedbackModal.close()
    $('.score-loader-modal').show()

    getSubmittedScores().then((scores) ->
      self.submittedScores = scores
      self.loadPhaseAssessments(getAssessments)
      self.checkCompletedPhase()
      self.handleMenuSelect()
      self.getOutputMetrics = getOutputMetrics
      $('.score-loader-modal').hide()
      self.showSubmitButton()
    )

  handlePhaseDropdown: (getAssessments, getSubmittedScores) ->
    self = @
    $("#phase-dropdown").on "selectmenuchange", ->
      self.removeCheckMarkOnSelect()
      self.profileUI.renderOnlyActivePhase()
      getSubmittedScores().then((scores) ->
        self.submittedScores = scores
        self.loadPhaseAssessments(getAssessments)
      )

  generateFrameworkDropdown: (assessments) =>
    frameworks = Object.keys(assessments)
    options = ""

    for framework in frameworks
      options += "<option>#{framework} #{@placeCompletedIcon(@checkCompletedFramework(framework))}</option>"

    $("#framework-dropdown").html(options)
    @removeCheckMarkOnSelect()

  generateCriteriumDropdown: (assessments, selectedFramework = Object.keys(assessments)[0]) =>
    criteria = if selectedFramework.length > 0 then Object.keys(assessments[selectedFramework]) else []
    options = ""

    for criterium in criteria
      options += "<option>#{criterium} #{@placeCompletedIcon(@checkCompletedCriterium(selectedFramework, criterium))}</option>"

    $("#criterium-dropdown").html(options)
    @removeCheckMarkOnSelect()

  getSelectedPhaseId: =>
    return $("#phase-dropdown").find(":selected").attr("value")

  generateScoreForm: (
    assessments,
    selectedFramework = Object.keys(assessments)[0],
    selectedCriterium = Object.keys(assessments[selectedFramework])[0]
  ) =>
    assessments = assessments[selectedFramework][selectedCriterium]
    form = ""
    @checkUserAccess()

    for assessment in assessments
      submittedScores = @submittedScores[@getSelectedPhaseId()][selectedFramework][selectedCriterium]
      assessmentRating = ""
      assessmentComment = ""

      if Object.keys(submittedScores).length != 0 and submittedScores[assessment.id]
        assessmentRating = submittedScores[assessment.id][0]
        assessmentComment = submittedScores[assessment.id][1]
        assessmentUpdatedAt = submittedScores[assessment.id][2]

      form += """<div class='score-form-wrapper score-form-container'>
                    <div class='assessment-submission'>
                      <div class="assessment-wrapper">
                        <p class='assessment-id' data-value='#{assessment.id}'> #{assessment.name} </p>
                      </div>
                      <div class="icon-wrapper">
                        <span class='material-icons information-icon'> info_outline </span>
                      </div>
                      <div class="button-wrapper">
                        <a class='submission-button'> Submission </a>
                      </div>
                    </div>
                    <select name='assessment-rating' id='assessment-rating' class='assessment-rating #{@checkUserAccess()}' #{@checkUserAccess()} >
                      <option value='' disabled #{@checkSelectedRating('', assessmentRating)}>-Select Rating-</option>
                      <option value='0' #{@checkSelectedRating(0, assessmentRating)}>Not Submitted</option>
                      <option value='1' #{@checkSelectedRating(1, assessmentRating)}>Below Expectations</option>
                      <option value='2' #{@checkSelectedRating(2, assessmentRating)}>At Expectations</option>
                      <option value='3' #{@checkSelectedRating(3, assessmentRating)}>Above Expectations</option>
                    </select>
                    <div>
                      <textarea class='leave-comment #{@checkUserAccess()}' placeholder='Leave Comments' #{@checkUserAccess()} >#{assessmentComment}</textarea>
                      <input class='original-updated-at' type='hidden' name='score[original_updated_at]' value='#{assessmentUpdatedAt}' />
                    </div>
                 </div>"""

    $("#score-form").html(form)
    @showOutputInfo(assessments)

    if localStorage.unsaved_scores
      unsavedScores = localStorage.unsaved_scores.split(',')
      scoreCards = $('.assessment-id')

      $.each(unsavedScores, (index, score) ->
        $.each(scoreCards, (key, value) ->
          if $(value).attr('data-value') == score
            $(value).parent().parent().find('.original-updated-at').after(
              "<span class='score-submit-error'>This record was just submitted by another admin. Resubmitting it will override their submission.</span>"
            )
        )
      )
      localStorage.removeItem('unsaved_scores')

    @jqueryDropdownUi.initializeDropdown()

  checkUserAccess: =>
    if $(".user-notice").length > 0
      return "disabled"

  checkSelectedRating: (optionValue, rating) =>
    if optionValue == rating
      return "selected"

  updateSelectionLabel: =>
    frameworkOptionText = $("#framework-dropdown").find(":selected").text()
    criteriumOptionText = $("#criterium-dropdown").find(":selected").text()
    selectedFramework = frameworkOptionText.slice(0, frameworkOptionText.lastIndexOf(" "))
    selectedCriterium = criteriumOptionText.slice(0, criteriumOptionText.lastIndexOf(" "))
    $("#selection-label").text("#{selectedFramework} - #{selectedCriterium}")

  handleFrameworkDropdown:(getSubmittedScores) =>
    self = @

    $("#framework-dropdown").on "selectmenuchange", ->
      frameworkOptionText = $(this).find(":selected").text()
      selectedFramework = frameworkOptionText.slice(0, frameworkOptionText.lastIndexOf(" "))
      self.removeCheckMarkOnSelect()

      getSubmittedScores().then((scores) ->
        self.submittedScores = scores
        self.generateCriteriumDropdown(self.assessments, selectedFramework)
        self.generateScoreForm(self.assessments, selectedFramework)
        self.updateSelectionLabel()
      )

  handleCriteriumDropdown:(getSubmittedScores) =>
    self = @

    $("#criterium-dropdown").on "selectmenuchange", ->
      frameworkOptionText = $("#framework-dropdown").find(":selected").text().split(" ")
      frameworkOptionText.pop()
      selectedFramework = frameworkOptionText.join(" ")
      criteriumOptionText = $(this).find(":selected").text().split(" ")
      criteriumOptionText.pop()
      selectedCriterium = criteriumOptionText.join(" ")
      self.removeCheckMarkOnSelect()

      getSubmittedScores().then((scores) ->
        self.submittedScores = scores
        self.generateScoreForm(self.assessments, selectedFramework, selectedCriterium)
        self.updateSelectionLabel()
      )

  getScoreData: =>
    scoreData = []

    $(".score-form-wrapper").each () ->
      phaseId = $("#phase-dropdown").find(":selected").attr("value")
      assessmentId = $(this).find("p").attr("data-value")
      score = $(this).find("select").val()
      comment = $(this).find('textarea').val()
      originalUpdatedAt = $(this).find('[name="score[original_updated_at]"]').val()

      scoreData.push({
        'phase_id': phaseId,
        'assessment_id': assessmentId,
        'score': score,
        'comments': comment,
        'original_updated_at': originalUpdatedAt
        })

    return scoreData

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)

  submitScore: (sendScoreData, checkBlankFields, backendValidation, getVerifiedOutputs) ->
    self = @
    $("#submit-score").click ->
      self.loaderUI.show()
      scoreData = self.getScoreData()
      blankFields = checkBlankFields(scoreData)

      if blankFields != ''
        self.loaderUI.hide()
        self.toastMessage("#{blankFields} cannot be blank", "error")
      else
        elementToObserve = document.querySelector('#confirm-backend-score-save')
        sendScoreData(scoreData)
        $("select").selectmenu({ style: 'dropdown' });
        backendValidation.toastMessage(elementToObserve,
                                      "Assessment(s) recorded",
                                      "Score(s) and Comment(s) cannot be blank",
                                      "You can't submit scores for an ended phase!!!"
                                      )
        self.updateCompletedStatusOnSubmit()
        $('input.original-updated-at').val(self.pgDateFormat(Date.now()))
        $('.score-submit-error').html('')
        self.loadVerifiedOutputs(getVerifiedOutputs)

  loadVerifiedOutputs: (getVerifiedOutputs) =>
    self = @

    getVerifiedOutputs(self.scoresURL).done((data) ->
        verified_outputs = data.verified_assessments
        assessments_count = data.assessments_count
        $('#vfd-out').text(verified_outputs + ' of ' + assessments_count)
    )

  showSubmitButton: =>
    $(".submit-scores").removeClass('submit-score-btn')

  checkCompletedCriterium:(selectedFramework, criterium) =>
    ratedCriteria = @submittedScores[@getSelectedPhaseId()][selectedFramework][criterium]
    availableAssessments = @assessments[selectedFramework][criterium]
    if Object.keys(ratedCriteria).length == availableAssessments.length then true else false

  checkCompletedFramework:(selectedFramework) =>
    completedFrameworkStatus = @submittedScores[@getSelectedPhaseId()][selectedFramework].completed
    return completedFrameworkStatus

  checkCompletedPhase: =>
    self = @

    $("#phase-dropdown option").each () ->
      if self.submittedScores[$(this).val()].completed
        $(this).text("#{$(this).text()} ✓")

  placeCompletedIcon:(checkCompletedStatus) =>
    if checkCompletedStatus then "✓" else ""

  checkCriteriumOnSubmit:(selectedFramework, selectedCriterium) =>
    availableAssessments = @assessments[selectedFramework][selectedCriterium]
    recentlyRated = []

    for scoreData in @getScoreData()
      if scoreData.score != null
        recentlyRated.push(true)

    if recentlyRated.length == availableAssessments.length then true else false

  updateCompletedStatusOnSubmit: =>
    selectedCriterium = $("#criterium-dropdown").find(":selected").text().trim()
    selectedFramework = $("#framework-dropdown").find(":selected").text().trim()

    if selectedCriterium.indexOf("✓") > -1
      selectedCriterium = selectedCriterium.slice(0, selectedCriterium.lastIndexOf("✓")).trim()

    if selectedFramework.indexOf("✓") > -1
      selectedFramework = selectedFramework.slice(0, selectedFramework.lastIndexOf("✓")).trim()

    if @checkCriteriumOnSubmit(selectedFramework, selectedCriterium)
      $("#criterium-dropdown").find(":selected").text("#{selectedCriterium} ✓")

    @checkCompletedStatusOnSubmit($("#criterium-dropdown option"), $("#framework-dropdown"))
    @checkCompletedStatusOnSubmit($("#framework-dropdown option"), $("#phase-dropdown"))
    $("select").selectmenu("destroy").selectmenu({ style: "dropdown" })
    @removeCheckMarkOnSelect()

  checkCompletedStatusOnSubmit:(options, optionToUpdate) =>
    totalOptions = options.length
    completedOptions = []

    options.each () ->
      if $(this).text().indexOf("✓") > -1
        completedOptions.push(true)

    if totalOptions == completedOptions.length
      targetOption = optionToUpdate.find(":selected")

      if targetOption.text().indexOf("✓") == -1
        checkIcon = if optionToUpdate.attr("id") == "phase-dropdown" then " ✓" else "✓"
        targetOption.text("#{targetOption.text()}#{checkIcon}")

  removeCheckMarkOnSelect: =>
    phaseOptionText = $("#phase-dropdown").find(":selected").text()
    frameworkOptionText = $("#framework-dropdown").find(":selected").text()
    criteriumOptionText = $("#criterium-dropdown").find(":selected").text()

    if frameworkOptionText.indexOf("✓") > -1
      $("#framework-dropdown-button .ui-selectmenu-text").text(frameworkOptionText.slice(0, frameworkOptionText.lastIndexOf(" ")))

    if criteriumOptionText.indexOf("✓") > -1
      $("#criterium-dropdown-button .ui-selectmenu-text").text(criteriumOptionText.slice(0, criteriumOptionText.lastIndexOf(" ")))

    if phaseOptionText.indexOf("✓") > -1
      $("#phase-dropdown-button .ui-selectmenu-text").text(phaseOptionText.slice(0, phaseOptionText.lastIndexOf(" ")))

  handleMenuSelect: =>
    self = @

    $("#framework-dropdown, #criterium-dropdown, #phase-dropdown").on "selectmenuselect", ->
      self.removeCheckMarkOnSelect()

  pgDateFormat: (date) ->
    parsed = new Date(date)

    zeroPad = (d) ->
      ('0' + d).slice -2

    [
      parsed.getUTCFullYear(), '-',
      zeroPad(parsed.getMonth() + 1), '-',
      zeroPad(parsed.getDate()), ' ',
      zeroPad(parsed.getHours()), ':',
      zeroPad(parsed.getMinutes()), ':',
      zeroPad(parsed.getSeconds())
    ].join('') + ' UTC'

  showOutputInfo: (outputInfo) =>
    self = @

    $('.information-icon').click ->
      selectedOutputId = $($(this).parent().prev().children()).attr('data-value')
      selectedOutputInfo = self.getOutputInfo(outputInfo, selectedOutputId)
      self.populateInfoModal(selectedOutputInfo, selectedOutputId)
      window.scrollTo(0, 0)
      self.outputInfoModal.open()
      $('body').css('overflow-y', 'hidden')

      $('.close-button, .close-modal').click ->
        self.outputInfoModal.close()
        $('body').css('overflow', 'auto')

  populateInfoModal: (outputInfo, id) ->
    self = @
    $('#output-info-modal').html(self.generateModalContent(outputInfo))

    self.getOutputMetrics(id).then (metrics) =>
      self.generateScoresTable(metrics)

  getOutputInfo: (infoList, id) =>
    self = @
    info = infoList.filter (info) -> info.id == Number(id)
    info

  generateModalContent: (outputInfo) ->
    """<div class="modal">
        <div class="modal-top">
          <div class="modal-header">
            <span class="close-button"></span>
            <div class="top-section">
              <div class="output-info-header">#{outputInfo[0].name}</div>
              <div class="line">
                <span class="long"></span>
                <span class="short"></span>
              </div>
            </div>
          </div>
          <div id="output-info-modal-content" class="modal-content">
            <div class="output-description">
              <h6 class="scroll-head">Description</h6>
              <p>#{outputInfo[0].description}</p>
            </div>
            <div class="output-context">
              <h6 class="scroll-head">Context</h6>
              <p>#{outputInfo[0].context}</p>
            </div>
            <div class="output-score"></div>
          </div>
        </div>
        <div class="output-info-modal-bottom">
        </div>
      </div>"""

  generateScoresTable: (metrics) ->
    scoresTable = """
      <table>
        <thead>
          <tr>
            <th>Score</th>
            <th>Score Description</th>
          </tr>
        </thead>
        <tbody>
    """
    $.each(metrics, (index, metric) ->
        scoresTable += """
        <tr>
          <td valign="top" class="score">#{index}</td>
          <td>#{metric.description}</td>
        </tr>
        """
      )

    scoresTable += "</tbody></table>"
    $('.output-score').html(scoresTable)

