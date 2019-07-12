class LearnerFeedbackView.UI
  constructor: (@fetchFeedback, @submitReflection, @fetchReflection, @updateReflection) ->
    @modal = new Modal.App('#learner-feedback-view', 916, 916, 612, 612)
    @activateAutoModal()

  selectPhaseChanged: () ->
    $('#learner-feedback-phase').on 'selectmenuchange', () =>
      phase_id = parseInt($('#learner-feedback-phase').val())
      framework_id = parseInt($('#learner-feedback-framework').val())
      @populateDropdown('#learner-feedback-output', @data.assessments[phase_id][framework_id])
      new_output_id= parseInt($('#learner-feedback-output').val())
      @fetchFeedback(phase_id, new_output_id, @afterFeedbackFetch)

  phaseFrameworkChanged: () ->
    $('#learner-feedback-framework').on 'selectmenuchange', () =>
      new_phase = parseInt($('#learner-feedback-phase').val())
      new_framework = parseInt($('#learner-feedback-framework').val())
      @populateDropdown('#learner-feedback-output', @assessments[new_phase][new_framework])
      new_output= parseInt($('#learner-feedback-output').val())
      @fetchFeedback(new_phase, new_output, @afterFeedbackFetch)

  selectOutputChanged: () ->
    $('#learner-feedback-output').on 'selectmenuchange', () =>
      new_phase_change = parseInt($('#learner-feedback-phase').val())
      new_framework_change = parseInt($('#learner-feedback-framework').val())
      new_output_change= parseInt($('#learner-feedback-output').val())
      @fetchFeedback(new_phase_change, new_output_change, @afterFeedbackFetch)

  selectFeedbackChanged: () ->
    $('#learner-multiple-feedback-output').on 'selectmenuchange', () =>
      new_feedback = parseInt($('#learner-multiple-feedback-output').val())
      $("#feedback-impression").html(@impressions[@feedback[new_feedback].impression_id - 1])
      $("#feedback-content-text").html(@feedback[new_feedback].comment)
      $(".btn-submit").data('feedbackId', "#{@feedback[new_feedback].id}")
      @fetchReflection(@feedback[new_feedback].id, @afterFetch)

  afterFeedbackFetch: (data) =>
    @impressions = data.all_impresions
    @populateDropdown('#learner-feedback-phase', data.all_phases)
    @populateDropdown('#learner-feedback-framework', data.all_frameworks)
    $("#learner-feedback-phase option:contains("+data.phase+")").attr('selected', true);
    $("#learner-feedback-framework option:contains("+data.framework+")").attr('selected', true);
    phase_id = parseInt($('#learner-feedback-phase').val())
    framework_id = parseInt($('#learner-feedback-framework').val())
    @populateDropdown('#learner-feedback-output', data.assessments[phase_id][framework_id])
    $("#learner-feedback-output option:contains("+data.output+")").attr('selected', true);

    $('#learner-feedback-phase').selectmenu('refresh', true);
    $('#learner-feedback-framework').selectmenu('refresh', true);
    $('#learner-feedback-output').selectmenu('refresh', true);

    @data = data
    @assessments = data.assessments

    $("#feedback-impression").removeClass("with-feedback")
    $("#feedback-content-text").removeClass("with-feedback")
    if data && data.learner_feedback
      $("#feedback-impression").addClass("with-feedback")
      $("#feedback-impression").html(data.impression)
      $("#feedback-content-text").addClass("with-feedback")
      $("#feedback-content-text").html(data.details)
      $(".btn-submit").data('feedbackId', "#{data.learner_feedback_id}")
      @feedback = data.learner_feedback
      @fetchReflection(data.learner_feedback_id, @afterFetch)
      @populateFeedBackDropdown('#learner-multiple-feedback-output', data.learner_feedback)
      $("#learner-multiple-feedback-output option:contains('Feedback 1')").attr('selected', true);
      $('#learner-multiple-feedback-output').selectmenu('refresh', true);
    else
      @hideSubmitButton()
      $("#feedback-impression").html("No Impression")
      $("#feedback-content-text").html("No Feedback Available")
      @populateFeedBackDropdown('#learner-multiple-feedback-output', [])
      $("#learner-multiple-feedback-output option:contains('No FeedBack')").attr('selected', true);
      $('#learner-multiple-feedback-output').selectmenu('refresh', true);


  openFeedbackViewModal: ->
    $('.learner-notification-link, .view-lfa-btn').off().click (event) =>
      @assessmentId = $(event.currentTarget).data('assessmentId')
      @phaseId = $(event.currentTarget).data('phaseId')
      @closeNotificationPane()
      @modal.open()
      @fetchFeedback(@phaseId, @assessmentId, @afterFeedbackFetch)
      @prepareModal()

    $('.close-learner-feedback-modal').click =>
      @closeModal()

  activateDropDowns: =>
    @populateDropdown('#learner-feedback-criteria', ['Initiative', 'Communication'])

  closeNotificationPane: =>
    $('.notifications-pane').animate({ right: '-263px' })
    $('body').css({ 'overflow': 'auto' })
    $('.notifications-pane-backdrop').hide()

  generateDropdown: (selectElement, selectOptions) =>
    selectElement.html('')
    selectElement.append(selectOptions)
    selectElement.selectmenu("refresh")

  populateDropdown: (elementId, data) =>
    $(elementId).html('')
    options = ""
    for key, selectOption of data
      options += "<option value='#{selectOption[0]}'>#{selectOption[1]}</option>"

    @generateDropdown($(elementId), options)

  populateFeedBackDropdown: (elementId, data) =>
    $(elementId).html('')
    options = ""
    unless data.length
      options += "<option value=''> No Feedback </option>"
    else
      for arr, idx in data
        options += "<option value='#{idx}'> Feedback #{idx + 1}</option>"

    @generateDropdown($(elementId), options)

  writeReflectionButton: =>
    boxShadow = (value)  =>
      $('.modal-bottom').css('box-shadow', value)
    $('.btn-submit').off().click =>
      $('.reflection-content-body').show()
      $('.btn-submit').hide()
      $('.btn-cancel').hide()
      $('.submit-refl').css('display', 'inline-block')
      boxShadow('0 0 0 0 rgba(0, 0, 0, 0.1)')
      $('.btn-wrapper').addClass('.refl-submit')
      $('.modal-content').animate({ scrollTop: 900 }, 'slow')
    boxShadow( '0 -2px 5px 0 rgba(0, 0, 0, 0.1)')
    $('.btn-wrapper').removeClass('refl-submit')
    $('.btn-cancel').show()

  submitReflectionButton: () =>
    $('.submit-refl').off().click =>
      comment = $(".reflection-content-text").val()
      if comment && comment.trim().length
        feedbackId = $(".btn-submit").data('feedbackId')
        @submitReflection(comment, feedbackId, @afterSubmit)
      else
        @showToastNotification("Reflection cannot be blank.", "warning")

  showToastNotification: (message, status) ->
    $('.toast').messageToast.start(message, status)

  afterSubmit: (data) =>
    @showToastNotification("Reflection has been submitted.", "success")
    Notifications.App.sendLfaLearnerReflection(data)
    @closeModal()

  afterUpdate: (data) =>
    @showToastNotification("Reflection has been updated.", "success")
    @closeModal()

  afterFetch: (data) =>
    if data
      if($(".reflection-content-body").is(":hidden"))
        $('.btn-submit').hide().html('View Reflection').show()
      $("textarea.reflection-content-text").val(data.comment)
      $('.submit-refl').html('Update Reflection')
      $('.submit-refl').off('click')
      $('.submit-refl').addClass('update-refl')
      $('.update-refl').off().click () =>
        comment = $(".reflection-content-text").val()
        feedbackId = $(".btn-submit").data('feedbackId')
        if comment && comment.trim().length
          @updateReflection(feedbackId, comment, @afterUpdate)
        else
          @showToastNotification("Reflection cannot be blank.", "warning")
    else
      $('.submit-refl').removeClass('update-refl')
      if($(".reflection-content-body").is(":hidden"))
        $('.btn-submit').hide().html('Write Reflection').show()
      $("textarea.reflection-content-text").val('')
      $('.submit-refl').html('Submit Reflection')
      $('.submit-refl').on('click')
      @submitReflectionButton()

  hideSubmitButton: ->
    $('.btn-submit').html('').hide()
    $('.submit-refl').off().hide()
    $(".reflection-content-body").hide()

  closeModal: =>
    $('.btn-submit').show()
    $('.submit-refl').removeClass('update-refl')
    $('.submit-refl').html('Submit Reflection')
    $('.submit-refl').hide()
    @modal.close()

  activateAutoModal: =>
    modalDetails = JSON.parse(localStorage.getItem('feedback_modal_data'))
    if modalDetails and !modalDetails.learner_program_id
      assessmentId = parseInt modalDetails.assessment_id
      phaseId = parseInt modalDetails.phase_id
      @modal.open()
      @fetchFeedback(phaseId, assessmentId, @afterFeedbackFetch)
      localStorage.removeItem('feedback_modal_data')
      @prepareModal()

  prepareModal: =>
    $('.reflection-content-body').hide()
    @writeReflectionButton()
    @submitReflectionButton()
    @selectPhaseChanged()
    @phaseFrameworkChanged()
    @selectOutputChanged()
    @selectFeedbackChanged()
