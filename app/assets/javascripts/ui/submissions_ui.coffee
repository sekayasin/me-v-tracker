class Submissions.UI extends LearningEcosystem.UI
  constructor: (
    @fetchPhases,
    @fetchFeedbackDetails,
    @getFeedbackMetadata,
    @fetchOutput,
    @fetchReflectionDetails,
    @fetchLearners
  ) ->
    super(@fetchPhases, @fetchOutput)
    @contentsPerPage = 18
    @learnersCount = ''
    @modal = new Modal.App('#lfa-feedback-view', "auto", "auto", "auto", "auto")
    @loaderUI = new Loader.UI()
    @assessmentName = ''
    @autoDisplayOutputModal()
    @phaseName = ''

  initializeAccordions: =>
    outputPage = document.getElementById("learner-outputs")
    if (outputPage)
      @loaderUI.show()
      @learnerProgramId = pageUrl[2]
      @fetchPhases(@afterPhasesFetch, @learnerProgramId)

    $(".learner-overview-container").click () ->
      @loaderUI.show()

    $("#back-to-learners").click () ->
      window.location.pathname = "/submissions"
    @activateReflectionAutoModal()

  populateLfaColumn: (assessment) =>
    if assessment["requires_submission"]
      unless assessment.submitted
        return $("<p></p>").text("N/A")
    unless assessment.feedback
      viewButton = @generateButtons("lfa-feedback-modal", "Give Feedback", {
        type: "assessment-id", value: assessment.id
      })
      return viewButton
    viewButton = @generateButtons("lfa-feedback-modal", "View Feedback", {
      type: "assessment-id", value: assessment.id
    })
    return viewButton

  populateViewSubmissionModal: (event) =>
    @assessmentId = $(event.currentTarget).attr("data-assessment-id")
    @phaseId = $(".phase-item.active").attr("data-phase-id")
    @loaderUI.show()
    @getFeedbackMetadata().then((response) =>
      impressions = response.impressions
      @populateDropdown("#impression-of-lfa", impressions, "Select feedback impression")
    ).then(() => @fetchOutput(@learnerProgramId, @phaseId, @assessmentId, @afterOutputFetch(event)))
    @loaderUI.hide()

  populateDropdown: (elementId, data, optionHeader = "") =>
    $(elementId).html('')
    options = ""
    if optionHeader != ""
      options = "<option value='' name='default' selected disabled> #{optionHeader} </option>"

    data.forEach((selectOption) =>(
      options += "<option value='#{selectOption.id}'>#{selectOption.name}</option>"
    ))

    @generateDropdown($(elementId), options)
  
  populateViewForAutoModalPopup: (assessment_id, phase_id) =>
    self = @
    @assessmentId = assessment_id
    @phaseId = phase_id
    @loaderUI.show()
    @getFeedbackMetadata().then((response) ->
        impressions = response.impressions
        self.populateDropdown("#impression-of-lfa", impressions, "Select feedback impression")
      ).then(() => @fetchOutput(@learnerProgramId, @phaseId, @assessmentId, @afterOutputFetch(null)))
    @loaderUI.hide()

  generateDropdown: (selectElement, selectOptions) =>
    selectElement.html ''
    selectElement.append selectOptions
    selectElement.selectmenu("refresh", true)

  clickViewSubmit: =>
    $(".lfa-feedback-modal").click (event) =>
      @phaseName = $('.phase-item.active').text()
      header = "#{$(event.currentTarget).children('.button-text').html()}"
      @modal.open()
      @loaderUI.show()
      @assessmentName = $(event.currentTarget).parent().siblings(":first").text()
      $('.phase-name').html("#{@phaseName  }")
      $('.assessment-name').html("#{@assessmentName}")
      $("#submission-and-feedback").trigger("click")
      @modal.setHeaderTitle(".submission-header", header)
      @clearFeedBackDetails()
      @clearReflectionDetails()
      @changeImpression()
      @populateViewSubmissionModal(event)
      $("#reflection-tab, #modal-bottom-reflection").hide()
      $('#submission-description').prop('disabled', true)
      $('#learner-reflect').prop('disabled', true)
    @closeButtonIcons()
    @activateSwitchTabs()
  
  autoDisplayOutputModal: ->
    modal_details = JSON.parse(localStorage.getItem('feedback_modal_data'))
    if modal_details and modal_details.learner_program_id
      assessmentName = $("[assessment-id=#{modal_details.assessment_id}]").text()
      phaseName = $("[learner-program-id=#{modal_details.learner_program_id}]").attr('phase-name')
      @modal.open()
      $('.phase-name').html("#{phaseName}")
      $('.assessment-name').html("#{assessmentName}")
      $("#submission-and-feedback").trigger("click")
      @clearFeedBackDetails()
      @clearReflectionDetails()
      @changeImpression()
      @populateViewForAutoModalPopup(
        modal_details.assessment_id,
        modal_details.phase_id
      )
      $("#reflection-tab, #modal-bottom-reflection").hide()
      $("#save-feedback-button").hide()
      $('#submission-description').prop('disabled', true)
      $('#learner-reflect').prop('disabled', true)
      @closeButtonIcons()
      @activateSwitchTabs()
      localStorage.removeItem('feedback_modal_data')


  clearFeedBackDetails: =>
    $('textarea#lfa-give-feedback').val("")

  clearReflectionDetails: =>
    $('textarea#learner-reflect').text("")

  createColumnContent: (assessment, key, index) =>
    switch
      when key is "requires_submission"
        if assessment[key]
          submitButton = $("<p></p>").text("Not Submitted")
          if assessment.submitted
            message = "View Submission"
            submitButton = @generateButtons("lfa-feedback-modal", message, {
              type: "assessment-id",
              value: assessment.id
            })
            submitButton.attr("id", "submit-for-#{assessment.id}")
          return submitButton
        $("<p></p>").addClass("requires-lfa-observation").text("Requires Your Observation")
      when key is "due_date"
        $("<p></p>").text(@fetchDueDate())
      when key is "lfa_feedback"
        @populateLfaColumn(assessment)
      when key is "description"
        @truncateText.generateContent(assessment.description, 110)
      when key is "output"
        @truncateText.generateContent(assessment.output, 110)
      else
        $("<p></p>").text(assessment[key])

  displayLearnerName: () =>
    for phase in @phases
      if phase.learner
        $(".submission-learner-name").attr("data-learner-program-id", phase["learner_program_id"])
        $(".submission-learner-name").text(phase.learner)
        $("span.learner-name").text(phase.learner.split(' ')[0])

  afterPhasesFetch: (phases) =>  
    unless @phases
      @phases = phases
      @populatePhasesBar()
      @populateOutcomesTable(@phases[0])
      @displayLearnerName()
      @loaderUI.hide()
      @clickTextArea()
      @changeImpression()
    $('#submissions-page-container').addClass('hidden')
    $("#learner-outputs").removeClass('hidden')

  clickTextArea: () =>
    $("#lfa-give-feedback").on("keyup", (event) =>
      @cancelOrSaveSwitch()
    )

  changeImpression: () ->
    $("#impression-of-lfa").on('selectmenuselect', =>
      @cancelOrSaveSwitch()
    )

  cancelOrSaveSwitch: =>
    if $('#lfa-give-feedback').val() || $('#impression-of-lfa').val()
      $('#cancel-give-feedback-modal').hide()
      $('#save-feedback-button').show()
    else
      $('#save-feedback-button').hide()
      $('#cancel-give-feedback-modal').show()

  closeButtonIcons: () =>
    $(".close-give-feedback-modal").click (event) =>
      @submitLfaFeedbackView()
      @modal.close()

  activateSwitchTabs: =>
    reflection = $("#reflection")
    submissionAndFeedback = $("#submission-and-feedback")
    reflection.on("click", () =>
      $("#feedback-form, #modal-bottom-submission").hide()
      reflection.addClass("active")
      $(".modal-header").text("View Reflection")
      $("#reflection-tab, #modal-bottom-reflection").show()
      $('.cancel-submission-btn').css("margin-right", 20)
      submissionAndFeedback.removeClass("active")
    )
    submissionAndFeedback.on("click", () =>
      $("#reflection-tab, #modal-bottom-reflection").hide()
      submissionAndFeedback.addClass("active")
      $(".modal-header").text("View Submission")
      $("#feedback-form, #modal-bottom-submission").show()
      reflection.removeClass("active")
    )

  afterOutputFetch: (event) => (output) =>
    if !output.outputs.length
      @outputId = @noValue
      $('.assignment-pdf').hide()
      $('.file-icon').hide()
      $('#a-view').hide()
      $('#a-download').hide()
      $('#submission-link-label').hide()
      $('#submission-link').hide()
      $('.lfa-view-late-submission').hide()
      $('#submission-description-label').hide()
      $('#submission-description').hide()
      $('.multiple-output-bar').hide()
      return @populateFeedbackAndReflectionSection(@fetchFeedbackDetails, @fetchReflectionDetails)

    @outputId = output.outputs[0].id
    @targetIsMultiple = output.is_multiple
    $('.multiple-output-bar').hide() unless @targetIsMultiple

    if @targetIsMultiple
      outputs = @configureOutputs(output)
      @configureMultipleSubmissions(outputs, output.submission_phases)
    else
      @configureSingleSubmission(output.outputs)

  configureOutputs: (output) =>
    outputs = []
    submissionPhases = Object.values(output.submission_phases).flat()

    getPhase = (out) ->
      submissionPhases.find((subPhase) ->
        return subPhase.id == out.submission_phase_id
      )
    pushOutput = (out) ->
      subData = getPhase(out)
      if subData
        outputs[subData.day - 1] = out

    pushOutput out for out in output.outputs
    return outputs

  configureSingleSubmission: (output, day=1) =>
    output = output[day - 1]
    unless output
      $('.assignment-pdf').hide()
      $('.file-icon').hide()
      $('#a-view').hide()
      $('#a-download').hide()
      $('#submission-link-label').hide()
      $('#submission-link').hide()
      $('#lfa-feedback-group').hide()
      $('.lfa-view-late-submission').hide()
      @hideAllLfaFeedbackView()
      $('#submission-description-label').html('<p style="text-align: center">Not submitted yet</p>').show()
      return $('#submission-description').hide()

    @outputId = output.id
    if output.file_link
      file_link = output.file_link
      [..., file_name_id] = output.file_link.split("/")
      $('.assignment-pdf').val("#{output.file_name}").show()
      $('#a-view').attr("href", "#{file_link}").show()
      $('#a-download').attr("href", "/download/#{file_name_id}").show()
    else
      $('.assignment-pdf').hide()
      $('.file-icon').hide()
      $('#a-view').hide()
      $('#a-download').hide()

    if output.link
      $('#submission-link-label').show()
      $('#submission-link').html("<a href=#{output.link} target=_blank>#{output.link}</a>").show()
    else
      $('#submission-link-label').hide()
      $('#submission-link').hide()
    $('#submission-description-label').html('Description').show()
    $('#submission-description').val("#{output.description}").show()
    due_date = moment.utc(@fetchDueDate()).endOf('day')
    submission_date = moment.utc(output.created_at)
    unless moment(submission_date).isSameOrBefore(due_date)
      formatted_date = submission_date.local().format("ddd MMM DD YYYY HH:mm")
      $('.lfa-view-late-submission').show()
      $('.lfa-view-late-submission').html("Submitted on: #{formatted_date} hrs (LATE)")
    else
      $('.lfa-view-late-submission').hide()
    @populateFeedbackAndReflectionSection(@fetchFeedbackDetails, @fetchReflectionDetails)

  configureMultipleSubmissions: (outputs, submission_phases) =>
    @populateSubmissionsTopTabs(submission_phases)
    @configureSingleSubmission(outputs)
    @registerClickListenersForTabs(outputs)

  registerClickListenersForTabs: (output) ->
    $('.multiple-output-bar li a').click (e) =>
      target = $(e.currentTarget).parent()
      $(target).siblings().removeClass('active')
      $(target).addClass('active')
      selectedDay = $(target).data('day')
      @configureSingleSubmission(output, selectedDay)

  populateSubmissionsTopTabs: (submission_phases) ->
    navigatorHtml = Object.keys(submission_phases).map((item) ->
      "<li class='multiple-output-item' data-day='#{item}'><a>Day #{item}</a></li>"
    )
    @cleanUpAndInsert('.multiple-output-bar', navigatorHtml.join(''))
    $('.multiple-output-bar').show()
    $('.multiple-output-item:visible').first().addClass('active')

  revealToast: (message, status) ->
    $('.toast').messageToast.start(message, status)

  validateFeedbackDetails: (impressionId, comment) =>
    valid = true
    unless impressionId?
      @revealToast("Choose an impression", "error")
      valid = false
    if comment.trim() == ""
      @revealToast("Write a feedback before submission", "error")
      valid = false

    return valid

  isValidReflection: (response) ->
    response?.comment? and !!response.comment.trim()

  populateFeedbackAndReflectionSection: (fetchFeedbackDetails, fetchReflectionDetails) =>
    data = {
      phase_id: @phaseId,
      assessment_id: @assessmentId,
      learner_program_id: @learnerProgramId,
      output_submissions_id: @outputId
    }

    data2 = {
      phase_id: @phaseId,
      assessment_id: @assessmentId,
      learner_program_id: @learnerProgramId,
    }

    $('#lfa-feedback-group').show()
    fetchFeedbackDetails(data).then((response) =>
      if !response && @targetIsMultiple == false
        fetchFeedbackDetails(data2).then((response) =>
          @populateFeedback(response)
          return response
        )
      else
        @populateFeedback(response)
        return response
    ).then((response) =>
      unless response
        $('div#no-reflection-container').show()
        $('textarea#learner-reflect').hide()
        $('label#reflection-label').hide()

      if response
        fetchReflectionDetails(response.id).then((response) =>
          unless response
            $('div#no-reflection-container').show()
            $('textarea#learner-reflect').text('').hide()
            $('label#reflection-label').hide()

          if @isValidReflection(response)
            $('label#reflection-label').show()
            $('textarea#learner-reflect').show()
            $('textarea#learner-reflect').text(response.comment)
            $('div#no-reflection-container').hide()
        )
    )

  populateFeedback: (feedback) =>
    unless feedback
      $('#impression-of-lfa').selectmenu({ disabled: false })
      $('#impression-of-lfa').selectmenu("refresh")
      $('#lfa-give-feedback').prop('disabled', false).val('')
      @submitLfaFeedbackView()

    if feedback
      $('#impression-of-lfa').val(feedback.impression_id).show()
      $('#impression-of-lfa').selectmenu("refresh")
      $('textarea#lfa-give-feedback').val(feedback.comment).show()
      if feedback.finalized
        @updateLfaFeedbackView()
      else
        @submitLfaFeedbackView()

  submitOrSaveFeedback: (saveFeedback) =>
    $('#post-feedback, #save-feedback-button').click (event) =>
      finalized = event.target.id == 'post-feedback' ? true : false
      impressionId = $('#impression-of-lfa').val()
      comment = $('textarea#lfa-give-feedback').val()

      isValidDetails = @validateFeedbackDetails(impressionId, comment)

      feedbackDetails = {
        impression_id: impressionId,
        comment: comment,
        phase_id: @phaseId,
        assessment_id: @assessmentId,
        output_submissions_id: @outputId
        learner_program_id: @learnerProgramId
        finalized: finalized,
      }
      if isValidDetails
        saveFeedback(feedbackDetails)
        @submitLfaFeedbackView()
        content = "<span class='button-text'>View Feedback</span>"
        $(".lfa-feedback-modal[data-assessment-id ='#{@assessmentId}']:contains('Give Feedback')").html(content)

  updateLfaFeedbackView: ->
    unless $("span.edit-feedback-icon").length
      $("span.edit-feedback-wrapper").append("<span class='edit-feedback-icon'></span>")
      $("span.edit-feedback-wrapper").append("<button class='clear-feedback-btn' hidden>Clear</button>")
      $("a.update-submission-btn, #save-feedback-button").hide()
      $('#lfa-give-feedback').prop('disabled', true)
      $( "#impression-of-lfa" ).selectmenu( "option", "disabled", true)
      @activateClearFeedbackButton()
      @editFeedbackIconAction()

  activateClearFeedbackButton: ->
    $('button.clear-feedback-btn').click (event) ->
      event.preventDefault()
      unless $("#lfa-give-feedback").prop('disabled')
        $("#lfa-give-feedback").val('')
        $('#save-feedback-button').hide()
        $('#cancel-give-feedback-modal').show()

  editFeedbackIconAction: ->
    $('span.edit-feedback-icon').click (event) ->
      $("#lfa-give-feedback").removeAttr('disabled')
      $("a.update-submission-btn").text("Update Feedback")
      $(".clear-feedback-btn").removeAttr('hidden')
      $('#save-feedback-button, a.update-submission-btn').show()
      $('#cancel-give-feedback-modal').hide()
      $( "#impression-of-lfa" ).selectmenu( "option", "disabled", false)

  submitLfaFeedbackView: ->
    $("span.edit-feedback-icon, .clear-feedback-btn").remove()
    $("#lfa-give-feedback, #impression-of-lfa").removeAttr('disabled')
    $("a.update-submission-btn").text("Submit Feedback")
    $("a.update-submission-btn, a#cancel-give-feedback-modal").show()
    $("a#save-feedback-button").hide()

  hideAllLfaFeedbackView: ->
    $("span.edit-feedback-icon, .clear-feedback-btn").remove()
    $("#lfa-give-feedback, #impression-of-lfa").removeAttr('disabled')
    $("a.update-submission-btn, a#cancel-give-feedback-modal").hide()
    $("a#save-feedback-button").hide()

  activateReflectionAutoModal: ->
    modalDetails = JSON.parse(localStorage.getItem('reflection_modal_data'))
    return unless modalDetails
    @modal.open()
    @loaderUI.show()
    @clearFeedBackDetails()
    @clearReflectionDetails()
    @changeImpression()
    $('#learner-reflect').prop('disabled', true)
    $("#reflection").trigger('click')
    $('.phase-name').html("#{modalDetails.phase_name}")
    $('.assessment-name').html("#{modalDetails.assessment_name}")
    @assessmentId = parseInt modalDetails.assessment_id
    @phaseId = parseInt modalDetails.phase_id
    @learnerProgramId = parseInt modalDetails.learner_program_id
    @getFeedbackMetadata().then((response) =>
      impressions = response.impressions
      @populateDropdown("#impression-of-lfa", impressions, "Select feedback impression")
    ).then(() => @fetchOutput(@learnerProgramId, @phaseId, @assessmentId, @afterOutputFetch(event)))
    $("#reflection-tab, #modal-bottom-reflection").hide()
    @closeButtonIcons()
    @activateSwitchTabs()
    @loaderUI.hide()

    localStorage.removeItem('reflection_modal_data')
