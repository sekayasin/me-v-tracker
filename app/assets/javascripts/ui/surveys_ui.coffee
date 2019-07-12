class Survey.UI
  constructor: (
    @getSurveys,
    @getAllCycles,
    @createSurvey,
    @updateSurvey,
    @getSurveysRecipients,
    @closeSurvey,
    @saveFeedback,
    @getFeedbackScheduleDetails,
    @saveScheduleFeedback,
    @deleteSurvey
  ) ->
    @loaderUI = new Loader.UI()
    @modal = new Modal.App('#create-survey', "auto", "auto", "auto", "auto")
    @learnerFeedbackPopupModal = new Modal.App('#learner-feedback-popup-modal', 620, 242, 448, 204)
    @closeSurveyConfirmationModal = new Modal.App('#close-survey-confirmation-modal', "auto", "auto", "auto", "auto")
    @deleteSurveyConfirmationModal = new Modal.App('#delete-survey-confirmation-modal', 500, 500, 255, 255)
    @scheduleFeedbackModal = new Modal.App('#schedule-feedback', 520, "auto", "auto", "auto")
    @pagination = new PaginationControl.UI()

    @feedbackScheduleInfo = []
    @isValidForm = false
    @recipients = []
    @centers = []
    @selectedCycles = []
    @newRecipients = []
    @surveys = []
    @surveyInfo = []
    @contentPerPage = 10
    @surveysCount = 0

  initializeFeedbackModal: =>
    @openScheduleFeedbackModal()
    @getScheduleDateRestriction()

  initializeSurveyModal: =>
    @populateSurveyTable()
    @openCreateSurveyModal()
    @selectRecipients()
    @handleSubmitClick()
    @handleUpdateClick()
    @submitSurveyForm()
    @initializeTooltip()
    @getSurveyDuration()
    @submitCloseSurvey(@surveyInfo)
    @closeFeedbackPopupModal()
    @saveScheduleFeedbackModal()
    @initializeLearnerFeedbackModal()

  initializeLearnerFeedbackModal: ->
    showAgain = localStorage.getItem('dontShowAgain')
    if showAgain is null
      $('#learner-feedback-popup-modal').css('display', 'block')


   initializeTooltip: () ->
     $( document ).tooltip({
       tooltipClass: "custom-tooltip-styling",
       position: { my: "left+15 center", at: "right center" }
     })

  initializeSurveyTable: () =>
    self = @
    if pageUrl[1] == 'surveys' && pageUrl.length == 2
      self.getSurveys(self.contentPerPage, self.pagination.page).then(
        (data) ->
          self.admin = data.admin
          self.surveys = data.paginated_data
          self.surveysCount = data.surveys_count
          self.populateSurveyTable(self.surveys)
          self.pagination.initialize(
            self.surveysCount, self.getSurveys,
            self.populateSurveyTable, self.contentPerPage,
            {}, ".pagination-control.surveys-pagination"
          )
      )

  populateQuestionsDropdown: () =>
    questions = @feedbackScheduleInfo.questions
    options = '<option value="">Question</option>'
    questions.forEach((question) => (
      options += "<option value='#{question.nps_question_id}'>#{question.question}</option>"
    ))
    $("#select_question").empty()
    $("#select_question").append(options)

  populateCenterDropdown: () =>
    $('#select_program'). on 'selectmenuselect',  =>
      program_id = $('#select_program').val()
      centers = @feedbackScheduleInfo.data[program_id]
      options = '<option value="">Center</option>'

      for key of centers
        center = centers[key]
        cycles = center.cycles
        options += "<option value='#{key}'>#{center.center_name}</option>"

      $("#select_center").empty()
      $("#select_center").append(options).selectmenu('refresh')

    $('#select_center').on 'selectmenuselect',  =>
      center = $('#select_center').val()
      if center
        program_id = $('#select_program').val()
        @cycles = @feedbackScheduleInfo.data[program_id][center].cycles
        @populateCycleDropdown()
      else
        @populateCycleDropdown([])

  populateCycleDropdown: () =>
    options = '<option value="">Cycle</option>'
    for cycle in @cycles
      options += "<option value='#{cycle[0]}'>#{cycle[1]}</option>"

    $("#select_cycle").empty()
    $("#select_cycle").append(options).selectmenu('refresh')

  getScheduleDateRestriction: () =>
    $('#select_cycle').on 'selectmenuselect',  =>
      selected_cycle = $('#select_cycle').val()
      for cycle in @cycles
        if cycle[0] == selected_cycle
          start_day = cycle[2].slice(0,10)
          end_day = cycle[3].slice(0,10)
          minDate = moment(start_day).format('DD MMM YYYY HH:mm')
          maxDate = moment(end_day).format('DD MMM YYYY HH:mm')

          dateTimePickerProps = {
            controlType: 'select',
            oneLine: true,
            stepMinute: 5,
            dateFormat: 'dd M yy',
            timeFormat: 'HH:mm',
            minDate: minDate,
            maxDate: maxDate,
          }
          $("#select_start_date_feedback").datetimepicker("destroy")
          $("#select_end_date_feedback").datetimepicker("destroy")
          $("#select_start_date_feedback").datetimepicker(dateTimePickerProps)
          $("#select_end_date_feedback").datetimepicker(dateTimePickerProps)

  populateSurveyTable: (surveys) =>
    self = @
    $(".survey-table").hide()
    if surveys && surveys.length
      self.generateTableRows(surveys)
      self.openEditSurveyModal(surveys, "#edit-survey")
      self.openEditSurveyModal(surveys, "#duplicate-survey")
      self.openDeleteConfirmationModal(surveys)
    else
      $(".survey-table").hide()
      $("#survey-body").html ""
      $(".survey-table-body-wrapper").
      append("<h3 class='center-blank-state-text no-data'>No data to show :(</h3>")

  generateTableRows: (surveys) ->
    $(".survey-table-body-wrapper").find("h3").remove()
    $(".survey-table").show()
    $("#survey-body").html ""
    tRows = ""
    surveys.forEach((survey) => (
      endDate = moment(survey.end_date)
      startDate = moment(survey.start_date)
      duration = @surveyDuration(startDate, endDate)

      if survey.status == "Completed"
        learnerLink =  "<span></span>"
        learnersStatus = "<span class='status_completed'>Completed</span>"
        timer = "Completed"
        isChecked = "disabled"
        title = 'Closed'

      else
        learnerLink =  "<span><a href=#{survey.link} id=#{survey.survey_id} target='blank'><span class='feedback_icon' title='Give feedback'></span></a></span></td>"
        learnersStatus = "<span class='status_in_progress'>In progress</span>"
        timer = @timeLeft(endDate)
        isChecked = "checked"
        title = 'Active'
      end_date = moment(survey.end_date)
      start_date = moment(survey.start_date)
      duration = @surveyDuration(start_date, end_date)

      tRows += "<tr class='survey-row-wrapper'>" +
        if @admin
          "<td class='title-data'><span>#{survey.title}</span></td>" +
            "<td class='date-data'><span>#{@formatDate(survey.created_at)}</span></td>" +
            "<td class='duration-data'><span>#{duration}</span></td>" +
            "<td class='status-data'><span><label class='switch warning' title = #{title}
              id='#{survey.survey_id}'><input type='checkbox'  id='#{survey.survey_id}' #{isChecked}>
              <span class='slider round'></span></label> </span></td>" +
          if survey.status == "Receiving Feedback"
            "<td class='action-data'>
            <span> <a class='fa fa-clone copy-icon' title='Duplicate Survey' id='duplicate-survey#{survey.survey_id}'></a>
            <a class='edit-icon active-survey-icon' title='Edit Survey' id='edit-survey#{survey.survey_id}'></a>
            <a class='fa fa-trash-o trash-icon active-survey-icon' title='Delete Survey' id='delete-survey#{survey.survey_id}' ></a> </span></td>"
          else
            "<td class='action-data'><span><a class='fa fa-clone  duplicate copy-icon' title='Duplicate Survey' id='duplicate-survey#{survey.survey_id}' ></a></span></td>"
        else
          "<td class='title-data'><span>#{survey.title}</span></td>" +
          "<td class='date-data'><span>#{timer}</span></td>" +
          "<td class='action-data'>" +
          learnerLink+
          "<td class='status-data'>#{learnersStatus}</td>"
    ))

    $("#survey-body").append(tRows)
    @openConfirmationModal()

  formatDate: (timeStamp) ->
    if timeStamp
      moment(timeStamp).format("DD MMM YYYY")

  formatDateTime: (timeStamp) ->
      moment(timeStamp).format("DD MMM YYYY HH:mm")

  timeLeft: (endDate) ->
    current = moment(new Date())
    duration = moment.duration(endDate.diff(current))
    hours = duration._data.hours
    diff = duration._data.days
    months = duration._data.months
    mins = duration._data.minutes

    if months == 0
      switch
        when diff == 0
          if hours == 0
            return "#{@pluralize(mins, 'minute')} left"
          return "#{@pluralize(hours, 'hour')},
          #{unless mins == 0 then  @pluralize(mins, 'min') } left"
        when diff >= 7
          weeks = Math.round(diff/7)
          return "#{@pluralize(weeks, 'week')} left"
        else
          return "#{@pluralize(diff, 'day')} left"
    "#{@pluralize(months, 'month')} left"

  pluralize: (count, val) ->
    type = if val.substring(0,1) == 'h' then 'an' else 'a'
    if count <= 0
      return "less than #{type} #{val}"
    if count == 1
      return "#{type} #{val}"
    return "#{count} #{val}s"

  openCreateSurveyModal: ->
    $('#new-survey-btn').on 'click', =>
      @resetAllFields()
      @modal.open()
      @displayHeader('#new-survey-btn')
      $('.update-survey-btn').hide()
      $('.create-survey-btn').show()
      $('.create-survey-btn').html('Create Survey')
      @closeSurveyModal()
      @getRecipients()

  resetScheduleFields: () ->
    $("#select_start_date_feedback").val("")
    $("#select_end_date_feedback").val("")
    $("#select_question").val("")
    $("#select_program").val("")
    $("#select_center").html("")
    $("#select_cycle").val("")

  openScheduleFeedbackModal: ->
    $('#schedule-feedback-btn').on 'click', =>
      @loaderUI.show()
      @getFeedbackScheduleDetails().then (data) =>
        @feedbackScheduleInfo = data
        @populateQuestionsDropdown()
        @loaderUI.hide()
        @scheduleFeedbackModal.open()
        $('#select_program').selectmenu().selectmenu('refresh', true)
        $('#select_center').selectmenu()
        $('#select_cycle').selectmenu()
        $('#select_question').selectmenu().selectmenu('refresh', true)
        $('.schedule-feedback-header').html('Schedule Feedback')
        $('.update-schedule-feedback-btn').hide()
        $('.schedule-feedback-btn').show()
        @populateCenterDropdown()

    $('#close-schedule-feedback-modal').on 'click', =>
      @resetScheduleFields()
      @scheduleFeedbackModal.close()

  validateFeedbackScheduleForm: ->
      program = $('#select_program').val()
      center_id = $('#select_center').val()
      cycle_id = $('#select_cycle').val()
      nps_question_id = $('#select_question').val()
      start_date = $('#select_start_date_feedback').val()
      end_date = $('#select_end_date_feedback').val()
      if !program || !center_id || !cycle_id ||!nps_question_id ||!start_date ||!end_date
        $('.toast').messageToast.start("Fill all form fields", "error")
        return false
      else
        @valid_schedule_data = {
          program: program,
          center_id: center_id,
          cycle_id: cycle_id,
          nps_question_id: nps_question_id,
          start_date: start_date,
          end_date: end_date
        }
        return true

  saveScheduleFeedbackModal: ->
    $("#schedule-feedback-button").on 'click', =>
      if @validateFeedbackScheduleForm()
        @loaderUI.show()
        @saveScheduleFeedback(@valid_schedule_data).then (data) =>
          @loaderUI.hide()
          if data.saved
            $('.toast').messageToast.start("Feedback scheduled", "success")
            @resetScheduleFields()
            @scheduleFeedbackModal.close()
          else
            $('.toast').messageToast.start("Feedback not scheduled!", "error")

  openConfirmationModal: ->
    $('.switch input').on 'click', (event) =>
      event.preventDefault()
      @.surveyActionTarget = event.target
      @surveyInfo.length = 0
      @surveyInfo.push(event)
      @closeSurveyConfirmationModal.open()
      @closeConfirmationModal()

  closeSurveyModal: =>
    self = @
    $('#close-survey-modal').on 'click', ->
      self.modal.close()

  closeConfirmationModal: =>
    self = @
    $('#close-confirmation-btn, .cancel-btn').on 'click', ->
      self.closeSurveyConfirmationModal.close()

  openDeleteConfirmationModal: (surveys)->
    $.each(surveys, (index, survey) =>
      $("#delete-survey#{survey.survey_id}").click (event) =>
        event.preventDefault()
        @deleteSurveyConfirmationModal.open()
        @closeDeleteConfirmationModal()
        @deleteConfirmationModal(survey.survey_id, event)
    )

  closeDeleteConfirmationModal: ->
    $('#close-confirmation-btn, .cancel-btn').on 'click', =>
      @deleteSurveyConfirmationModal.close()

  deleteConfirmationModal: (id, rowEvent)->
    $('#confirm-delete-survey, .btn-submit').on 'click', =>
      @deleteSurvey(id)
      $(rowEvent.target).parents('tr').remove()
      @deleteSurveyConfirmationModal.close()
      $('.toast').messageToast.start("Survey deleted successfully", "success")

  submitCloseSurvey: (surveyInfo) ->
    $('#confirm-close-survey').on 'click', =>
      @surveyActionTarget.checked = false
      @surveyActionTarget.disabled = true
      @loaderUI.show()
      localStorage.setItem('isTrigger', true)
      @closeSurvey(self.afterError, surveyInfo[0].currentTarget.id).then (data) =>
        @loaderUI.hide()
        @closeSurveyConfirmationModal.close()
        if data.saved
          $('.toast').messageToast.start("Survey closed successfully", "success")
          @updateTable(surveyInfo[0], data.survey)
          updatedSurvey = @surveys.map((survey) -> survey.survey_id ).indexOf(data.survey.survey_id)
          @.surveys[updatedSurvey] = data.survey if updatedSurvey > -1
        else
          $('.toast').messageToast.start(data.errors, "error")

  updateTable: (surveyInfo, data) ->
    parent = 'tr.survey-row-wrapper'
    surveyAction = $(surveyInfo.currentTarget).parents(parent).children()[4]
    $(surveyAction).find(".active-survey-icon").remove()

  onReceiveSurvey: (content) ->
    trigger = localStorage.getItem('isTrigger')
    currentPathname = window.location.pathname
    if !trigger and currentPathname == '/surveys'
      if content.action == 'close'
        surveyRow = $("##{content.survey.survey_id}").parents('tr.survey-row-wrapper')
        unless content.email.includes('@andela.com')
          surveyRow.children('td.status-data').html("<span class='status_completed'>Completed</span>")
          surveyRow.children('td.action-data').children().html('<span></span>')
          surveyRow.children('td.date-data').children().text('Completed')
        else
          surveyRow.children('td.status-data').text(content.survey.status)
          surveyRow.children('td.action-data').children().remove()
      else
        $(".reload-container").show()
    localStorage.removeItem('isTrigger')

  populateDropdown: =>
    options = "<option value='' name='default' selected disabled>Add Cycle</option>"
    if @recipients.length
      $("#select-recipients").html('')

      @recipients.forEach((selectOption) -> (
        options += "<option value='#{selectOption.cycle_center_id}'>" +
          "Cycle #{selectOption.cycle} -- #{selectOption.name}</option>"
      ))
    @generateDropdown(options)

  generateDropdown: (selectOptions) ->
    selectElement = $("#select-recipients")
    selectElement.html ''
    selectElement.append selectOptions
    selectElement.selectmenu("refresh", true)

  openEditSurveyModal: (surveys, actionId) =>
    $.each(surveys, (index, survey) =>
      $("#{actionId}#{survey.survey_id}").click () =>
        @modal.open()
        @displayHeader(actionId)
        $('#update-survey-button').show()
        $('#update-survey-button').attr("survey_id", survey.survey_id)
        if actionId == '#edit-survey'
          $('#update-survey-button').show()
          $('#create-survey-button').hide()
        else
          $('#create-survey-button').show()
          $('#update-survey-button').hide()
          $('#create-survey-button').html('Save')
        @resetAllFields()
        $("#title").val(survey.title)
        $("#link").val(survey.link)
        $("#select_start_date_survey").val(@formatDateTime(survey.start_date))
        $("#select_end_date_survey").val(@formatDateTime(survey.end_date))
        @getRecipients(survey.survey_id)
        @closeSurveyModal()
    )

  displayHeader: (actionId) =>
    $(".create-survey-header").html(@surveyHeaderText(actionId))
    if actionId == '#edit-survey'
      $('#update-survey-button').html('Update')
    else
      $('#update-survey-button').html('Save')

  surveyHeaderText: (actionId) ->
    switch actionId
      when "#edit-survey" then "Edit Survey"
      when "#duplicate-survey" then "Duplicate"
      when "#new-survey-btn" then "Create survey"

  handleSubmitClick: () ->
    self = @
    $("#create-survey-button").click ->
      self.api = self.createSurvey
      self.message = "Survey successfully created"
      $("#create-survey-form").submit()

  handleUpdateClick: () ->
    self = @
    $("#update-survey-button").click ->
      self.api = self.updateSurvey
      self.message = "Survey updated successfully"
      $("#create-survey-form").submit()

  getSurveyDuration: ->
    $("#select_end_date_survey").on 'change', (event) =>
      @showSurveyDuration()
    $("#select_start_date_survey").on 'change', (event) =>
      @showSurveyDuration()

  showSurveyDuration: ->
    start_date = moment(new Date($("#select_start_date_survey").val()))
    end_date = moment(new Date($("#select_end_date_survey").val()))
    duration = @surveyDuration(start_date, end_date)
    $("#survey-duration").html(" <u>" + duration + "</u>")

  submitSurveyForm: () =>
    self = @
    $(".create-survey-form").on 'submit', (event) ->
      event.preventDefault()
      self.validateForm()
      if self.isValidForm
        self.loaderUI.show()
        form_data = self.getFormData()
        localStorage.setItem('isTrigger', true)
        form_data = self.getFormData()
        self.api(self.afterError, self.getFormData()).then (data) ->
          self.loaderUI.hide()
          if data.saved
            self.surveys = [data.survey].concat self.surveys
            $('.toast').messageToast.start(self.message, "success")
            self.modal.close()
            self.resetAllFields()
            self.initializeSurveyTable()
          else
            self.handleServerErrors(data.errors)

  handleServerErrors: (errors) ->
    for error in Object.entries(errors)
      for message in error[1]
        $(".toast").messageToast.start("#{error[0]} #{message}", "error")

  validateForm: () =>
    self = @
    $(".create-survey-form .field-required").each (index, element) ->
      self.isValidForm = true
      unless $(element).val()
        $('.toast').messageToast.start("All fields are required", "error")
        self.isValidForm = false

    if self.isValidForm
      link_regex = /^https?:\/\/[a-z0-9]+[\-_\.]{1}?[a-z0-9]+\.?[a-z]{2,5}?\/?.*?$/
      link = $("#link").val()
      unless link_regex.test(link)
        $('.toast').messageToast.start("Survey link provided is not valid", "error")
        self.isValidForm = false

    if self.isValidForm
      unless @selectedCycles.length
        $('.toast').messageToast.start("Recipients not selected", "error")
        self.isValidForm = false

    startDate = $("#select_start_date_survey").val()
    endDate = $("#select_end_date_survey").val()
    unless moment(startDate).isValid()
      $('.toast').messageToast.start("Invalid start date", "error")
      self.isValidForm = false
    unless moment(endDate).isValid()
      $('.toast').messageToast.start("Invalid end date", "error")
      self.isValidForm = false
    unless(moment(endDate).isAfter(moment(startDate)))
      $('.toast').messageToast.start("End date must be greater than start date", "error")
      self.isValidForm = false

  formatDateDB:(date) =>
    (new Date(date)).toISOString()

  getFormData: () =>
    schedule_survey = $("#schedule-survey").is(":checked")
    if schedule_survey
        start_date = @formatDateDB($("#select_start_date_survey").val())
        end_date =  @formatDateDB($("#select_end_date_survey").val())

    return {
      survey: {
        title: $("#title").val(),
        link: $("#link").val(),
        survey_id: $('#update-survey-button').attr("survey_id")
        start_date: @formatDateDB($("#select_start_date_survey").val())
        end_date: @formatDateDB($("#select_end_date_survey").val())
      }
      recipients: @selectedCycles.map((cycle) -> (cycle.cycle_center_id))
    }

  resetAllFields: () ->
    $(".field-required").val("")
    $("#cycle-pills").html("")
    @selectedCycles = []
    $("#select_start_date_survey").val("")
    $("#select_end_date_survey").val("")
    $("#survey-duration").html("")

  getRecipients: (survey_id) ->
    @loaderUI.show()
    @getAllCycles(@afterError).then (data) =>
      @loaderUI.hide()
      @recipients = data.recipients
      @getSelectedRecipients(survey_id)
      @populateDropdown()

  getSelectedRecipients: (survey_id) ->
    self = @
    self.loaderUI.show()
    self.getSurveysRecipients(self.afterError, survey_id).then (data) ->
      $.each(data.recipients, (index, recipient) ->
        self.addToSelectedCycle(recipient.cycle_center_id)
      )
      self.loaderUI.hide()

  afterError: () =>
    @loaderUI.hide()
    @modal.close()
    $('.toast').messageToast.start("Internal Server Error", "error")

  selectRecipients: () =>
    self = @
    $('#select-recipients').on 'selectmenuchange', (error, target) ->
      self.addToSelectedCycle(target.item.value)

  addToSelectedCycle: (cycle_center_id) =>
    selectedCycles = @recipients.filter (x) ->
      x.cycle_center_id == cycle_center_id
    @selectedCycles.push(selectedCycles[0])

    @recipients =  @recipients.filter (x) ->
      x.cycle_center_id != cycle_center_id

    @createCyclePill()
    @populateDropdown(@newRecipients)

  onCycleRemove: (option) =>
    @selectedCycles =  @selectedCycles.filter (x) ->
      x.cycle_center_id != option.cycle_center_id

    @recipients = [option].concat @recipients

    @createCyclePill()
    @populateDropdown()

  createCyclePill: () =>
    self = @
    $("#cycle-pills").html ""
    pills = ""
    @selectedCycles.forEach((option) -> (
      name = "#{option.name} (#{option.cycle})"
      cyclePill = $("<div></div>").addClass("cycle-pill")
      cyclePill.attr("id", option.cycle_center_id)
      nameofCycle = $("<span></span>").addClass("name-of-cycle")
      nameofCycle.text(name)
      removeCycle = $("<img />").addClass("remove-cycle")
      removeCycle.attr("id", option.cycle_center_id)
      removeCycle.attr("src", "/assets/close-circle.svg")
      removeCycle.on("click", () -> self.onCycleRemove(option))
      cyclePill.append(nameofCycle)
      cyclePill.append(removeCycle)
      $("#cycle-pills").append(cyclePill)
    ))

  surveyDuration: (startDate, endDate) ->
    duration = moment.duration(endDate.diff(startDate))
    days = duration._data.days
    if days == 0
      "#{@pluralize(duration._data.hours, 'hour')}"
    else if days < 7
      res = "#{@pluralize(duration._data.days, 'day')}"
      if duration._data.hours > 0
        res += ", #{@pluralize(duration._data.hours, 'hour')}"
      res
    else
      weeks = Math.round(days/7)
      days = Math.round(days%7)
      if weeks < 4
        res = "#{@pluralize(weeks, 'week')}"
        if days > 0
          res += ", #{@pluralize(days, 'day')}"
        res
      else
        "#{@pluralize(duration._data.months, 'month')}"

  activateEmoji: ->
    @feedback = {
        rating: '',
        question: $( "#feedback-question" ).text().trim(),
        program: '',
        comment: '',
    }
    $( ".emoji-ratings" ).off('click').on 'click', ((event) =>
      ratingId = $(event.target).attr('id')
      ratingValue = $(event.target).attr('value')
      if !ratingId || ! ratingValue
        return false
      if ratingId == 'ninth-rating' || ratingId == 'tenth-rating'
        @feedback.rating = parseInt(ratingValue)
        @feedback.comment = ''
        @feedback.program = $( "div.feedback-question").data('id')
        @saveFeedback(@feedback)
        .then((response) =>
          sessionStorage.removeItem('feedback-pop')
          @displaySucessMessage())
      else
        @feedback.rating = parseInt(ratingValue)
        $('.feedback-rating, .save-btn').show()
    )

    $('#save-feedback').off('click').on 'click', (event) =>
      feedbackComment = $("#popup-textarea").val()
      @feedback.comment = feedbackComment if feedbackComment.length > 1
      @feedback.program = $( "div.feedback-question").data('id')
      @saveFeedback(@feedback, "/program/feedback/create")
      .then((response) =>
        sessionStorage.removeItem('feedback-pop')
        @displaySucessMessage())

  displaySucessMessage: ->
    $('#learner-feedback-popup-modal').hide()
    $('.toast').messageToast.start("Thank you for your feedback", "success")

  displayDontShowAgainMessage: ->
    $('#learner-feedback-popup-modal').hide()
    $('.toast').messageToast.start("The popup won't show again.", "success")

  closeFeedbackPopupModal: =>
    $('.close-feedback-popup-modal').on 'click', =>
      if $('#show-again').is(':checked')
        localStorage.setItem('dontShowAgain', true)
        @displayDontShowAgainMessage()
      sessionStorage.removeItem('feedback-pop')
      $("#learner-feedback-popup-modal").hide()
      $(".feedback-popup-container").css("display", "none")

  openFeedbackPopupModal: (feedback) ->
    checked = localStorage.getItem('dontShowAgain')
    unless checked
      unless sessionStorage.getItem('feedback-pop')
        sessionStorage.setItem('feedback-pop', JSON.stringify(feedback))
      $("#feedback-question").html('').html(feedback.question)
      $("#feedback-question").attr('data-id', feedback.learner_program)
      $("#learner-feedback-popup-modal").show()
      $(".feedback-popup-container").css("display", "block")
      @activateEmoji()

  openFeedbackModalOnLoad: =>
    feedback = sessionStorage.getItem('feedback-pop')
    if feedback
      @openFeedbackPopupModal(JSON.parse(feedback))

  setTimeout ->
    sessionStorage.removeItem('feedback-pop')
    $("#learner-feedback-popup-modal").hide()
    $(".feedback-popup-container").css("display", "none")
  , 3600000 * 2
