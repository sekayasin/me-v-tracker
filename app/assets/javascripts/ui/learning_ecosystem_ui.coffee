class LearningEcosystem.UI
  constructor: (@fetchPhases, @fetchOutput, @submitOutput, @updateOutput) ->
    @modal = new Modal.App('#learner-output-submission', 537, 537, "auto", "auto")
    @multipleOutputModal = new Modal.App('#multiple-output-submission', "auto", "auto", "auto", "auto")
    @submissionModal = new Modal.App('#view-output-submission', "auto", "auto", "auto", "auto")
    @api = new LearningEcosystem.API()
    @loaderUI = new Loader.UI()
    @learnerFeedbackView = new LearnerFeedbackView.App()
    @truncateText = new TruncateText.UI()
    @current_output = null
    @assessmentSubmitId = null
    @file = null
    @submissionData = {}
    @permittedTypes = ['file', 'link', 'file, link']
    @assessmentMap = {}
    @submissionPhasesMap = {}
    @defaultSubmissionData = {
      file: "",
      link: "",
      description: ""
    }
    @phaseIndex = 0
    @currentAssessmentId = null
    @assessmentName = ""
    @phaseName = ""

  initializeTabs: (tabsId) ->
    $(".#{tabsId}-container").hide()
    $(".#{tabsId}-container:first").show()
    $("##{tabsId} li a").click ->
      anchorId = $(this).attr('id')
      listItem = $(this).parent()

      if !listItem.hasClass('active')
        $("##{tabsId} li").removeClass 'active'
        listItem.addClass 'active'
        $(".#{tabsId}-container").hide()
        $("##{anchorId}-content").fadeIn 'slow'
      return
    return

  initializeMultipleOutputSubmissionModalTabs: (tabsId) ->
    $("##{tabsId} li a").click ->
      anchorText = $(this).text()
      listItem = $(this).parent()

      if !listItem.hasClass('active')
        $("##{tabsId} li").removeClass 'active'
        listItem.addClass 'active'

      if anchorText != "Day 1"
        $("#multiple-output-submission input").prop("disabled", true)
        $("#multiple-output-submission textarea").prop("disabled", true)
        $("#multiple-output-submission-form .drop-area").css('cursor', 'not-allowed')
        $("#multiple-output-submission-form .drop-area-text").css('cursor', 'not-allowed')
        $("#save-multiple-output-submission").hide()
        $(".disabled-save-output-btn").show()
      else
        $("#multiple-output-submission input").prop("disabled", false)
        $("#multiple-output-submission textarea").prop("disabled", false)
        $("#multiple-output-submission-form .drop-area").css('cursor', 'pointer')
        $("#multiple-output-submission-form .drop-area-text").css('cursor', 'pointer')
        $("#save-multiple-output-submission").show()
        $(".disabled-save-output-btn").hide()
      return
    return

  closeAllPhasesTabAccordionIcons: (event) ->
    $(".phase-image-down").hide()
    $(".phase-image-right").show()

  initializeAccordions: ->
    self = @

    $(document).on 'ready', ->
      $(".phase-accordion").removeClass('hidden')

    $("#overview-tab").on("click", () =>
      window.location.href= "/learner/ecosystem" if self.onPhasesTab
    )

    $("#phases-tab").click () ->
      self.onPhasesTab = true
      unless self.phases
        self.loaderUI.show()
        self.fetchPhases(self.afterPhasesFetch)

    $(".accordion-section-title").click (event) ->
      event.preventDefault()
      self.closeAllPhasesTabAccordionIcons()
      chevronRight = $(this).find(".phase-image-right")
      chevronDown = $(this).find(".phase-image-down")
      if $(event.currentTarget).is('.active')
        chevronRight.show()
        chevronDown.hide()
      else
        chevronRight.hide()
        chevronDown.show()

    @clickOutputSubmit()
    @clickViewSubmit()

  validateOutput: ->
    valid = true
    error = 'All fields are required'
    stripMarkersOffSubmission = =>
      submission = Object.assign({}, @submissionData)
      delete submission['submitted']
      delete submission['index']
      delete submission['id']
      return submission

    submissionValues = Object.values(stripMarkersOffSubmission())
    self = @

    checkForEmptyValuesInSubmission = ->
      return submissionValues.filter((item) -> !item).length

    isNotEmpty = (key) ->
      return self.submissionData[key] && self.submissionData[key].length

    unless submissionValues.length && !checkForEmptyValuesInSubmission()
      valid = false
    if @submissionTypes && @permittedTypes.includes(@submissionTypes)
       unless isNotEmpty(@submissionTypes) && isNotEmpty('description') then valid = false
    if @submissionTypes is "file, link"
      unless isNotEmpty('description')
        error = "Please enter a description for your submission"
        valid = false
      if isNotEmpty('file') || isNotEmpty('link')
         if isNotEmpty('description') then valid = true
      else
        error = "Please submit either a valid link or upload a submission :)"
    unless valid
      $(".toast").messageToast.start(error, 'error')
    return valid

  gatherOutputDetails: () =>
    yieldSubmissionPhaseId = () =>
      return null unless @targetIsMultiple
      parseInt(@submissionData.fingerprint.split('-')[0])
    formData = new FormData()
    formData.append('assessment_id', @assessmentSubmitId)
    formData.append('phase_id', @currentPhaseId)
    formData.append('output_id', @submissionData.id)
    formData.append('link', @submissionData.link || '')
    if (@filesUploadedMap && Object.keys(@filesUploadedMap).length) || @file
     formData.append('submission_file', @yieldFileUploaded())
    formData.append('description', @submissionData.description)
    formData.append('submission_phase_id', yieldSubmissionPhaseId())
    formData

  yieldFileUploaded: ->
    return  @file unless @targetIsMultiple
    return @filesUploadedMap[@submissionData.fingerprint] if @submissionData.file
    null

  setAssessmentToSubmitted: (assessmentId, phaseId) =>
    phase = @phases.find((phase) => phase.id is phaseId)
    if phase
      assessment = phase.assessments.find((assessment) =>assessment.id is assessmentId)
      assessment.submitted = true if assessment

  afterSuccessfulSubmit: (data) =>
    document.getElementById("learner-submission-form").reset()
    @setAssessmentToSubmitted(data.assessment_id, data.phase_id)
    submitButton = $("#submit-for-#{data.assessment_id}")
    submitButton.off()
    submitButton.removeClass("enter-submission-btn").addClass("view-submission-btn")
    submitButton.html("<span class='button-text'>View Submission</span>")
    @modal.close()
    @flushAllValuesAfterModalIsClosed()
    @clickViewSubmit()
    @initialState()
    $(".toast").messageToast.start("Output submitted successfully", "success")
    Notifications.App.sendLfaOutputSubmissionNotification(data)

  afterSuccessUpdate: () =>
    $(".toast").messageToast.start("Output successfully updated", "success")
    @modal.close()
    @flushAllValuesAfterModalIsClosed()

  afterFailedSubmit: (errors) ->
    for entry in Object.entries(errors)
      for message in entry[1]
        $(".toast").messageToast.start("#{entry[0]} #{message}", "error")

  afterSubmit: (response) =>
    $("#submit-loader-modal").addClass("hidden")
    response_object = {
      assessment_id: response.assessment_id,
      lfa: response.lfa,
      phase_id: response.phase_id,
      output_name: response.output_name,
      learner_name: response.learner_name,
      learner_programs_id: response.learner_programs_id,
      phase_name: response.phase_name
    }
    return @afterSuccessfulSubmit(response_object) if response.saved
    @afterFailedSubmit(response.errors)

  afterUpdate: (response) =>
    $("#submit-loader-modal").addClass("hidden")
    return @afterSuccessUpdate() if response.saved
    @afterFailedSubmit(response.errors)

  afterUpdate: (response) =>
    $("#submit-loader-modal").addClass("hidden")
    return @afterSuccessUpdate() if response.saved
    @afterFailedSubmit(response.errors)

  initialState: () ->
    $('.drop-area').show()
    $('.fileUpload').val("")
    $('#link').val("")
    $('#description').val("")
    $('.uploaded-file').hide()

  validateFile: (file) ->
    $('#file_error').hide()
    valid = true unless file.size > 2048000
    regex = new RegExp('(.*?).(png|jpg|jpeg|gif|bmp)$')
    expectedFormat = true unless !regex.test(file.name)
    unless valid
      $('.file_error').show()
      $('.file_error').html('Upload should be less than 2MBs')
    unless expectedFormat
      $('.file_error').show()
      $('.file_error').html('Please Upload an Image file')
    valid && expectedFormat

  setDropedFile: () =>
    self = @
    $('.drop-area').on('drag dragstart dragend dragover dragenter dragleave drop', (e) ->
      e.preventDefault()
      e.stopPropagation()
      return
    ).on('dragover dragenter', ->
      $('.drop-area').addClass 'is-dragover'
      return
    ).on('dragleave dragend drop', ->
      $('.drop-area').removeClass 'is-dragover'
      return
    ).on 'drop', (e) ->
      self.file = e.originalEvent.dataTransfer.files[0]
      self.setFileName()

  setFileName: (file) =>
    file = @file unless file?
    unless @validateFile(file)
      return
    $('.uploaded-file').removeClass('hidden')
    $('.uploaded-file-name:visible').html("#{file.name}")
    $('.drop-area').hide()
    $('.file_error').hide()

  setUploadedFile: (e) =>
        return unless e
        unless @targetIsMultiple
          @file = $(e.currentTarget)[0].files[0]
          return @setFileName()
        temporaryHolder = {}
        identifier = $(e.currentTarget).data('identifier')
        temporaryHolder[identifier] = $(e.currentTarget)[0].files[0]
        @setFileName(temporaryHolder[identifier])
        @clearFilesubmit()
        @filesUploadedMap = Object.assign({}, @filesUploadedMap, temporaryHolder)

  clearFilesubmit: () =>
    $('.remove-file').click (event) =>
      @file = null
      $('.submission-for-upload').removeClass('hidden')
      $('.uploaded-file').addClass('hidden')
      @submissionData.file = ''
      if @targetIsMultiple
        identifier = $(event.currentTarget).data('identifier')
        day = $(event.currentTarget).data('day')
        index = $(event.currentTarget).data('index')
        @filesUploadedMap && delete @filesUploadedMap[identifier]
        @submissionPhasesMap[day][index] = $('.learner-submission-form:visible').html()
        @submissionMap[day][identifier]['file'] = ''

  clickOutputSubmit: ->
    self = @
    $('.uploaded-file').hide()
    self.setDropedFile()
    self.setUploadedFile()
    self.clearFilesubmit()

    $(".field-required").on("keyup", (event) =>
      target = $(event.currentTarget)
      if target.val()
        target.prev().find(".required-symbol").removeClass("error-mode")
      else
        target.prev().find(".required-symbol").addClass("error-mode")
    )

    $("#close-learner-modal").click (event) =>
      self.initialState()
      @modal.close()
      @flushAllValuesAfterModalIsClosed()

    $("#cancel-learner-submission").click (event) =>
      self.initialState()
      @modal.close()
      @flushAllValuesAfterModalIsClosed()

    $("#learner-submission-form").submit (event) => event.preventDefault()

    @registerSaveButtonListener()

  changePhase: (parent, phaseIndex) =>
    $(".phase-item").removeClass("active")
    parent.addClass("active")
    $(".phases-tab").find(".accordion-section-content.phase-content").empty()
    @populateOutcomesTable(@phases[phaseIndex])
    @phaseIndex = phaseIndex
    @learnerFeedbackView.start()

  createPhaseBarItem: (phaseName, phaseIndex, phaseId = "") =>
    phaseItemElement = $("<li></li>")
    phaseItemElement.addClass("phase-item")
    if !!phaseId
      phaseItemElement.attr("data-phase-id", phaseId)
    phaseItemElement.addClass("active") if phaseIndex is 0
    phaseNameElement = $("<a></a>")
    phaseNameElement.text(phaseName)
    phaseNameElement.on("click", (event) => @changePhase($(event.currentTarget).parent(), phaseIndex))
    phaseItemElement.append(phaseNameElement)
    return phaseItemElement

  populatePhasesBar: () =>
    phaseBarContainer = $("#phases-bar")
    for phase, index in @phases
      phaseItemElement = @createPhaseBarItem(phase.name, index, phase.id)
      phaseBarContainer.append(phaseItemElement)

  createTableHead: () ->
    tableHeaderRow = $("<tr></tr>").addClass("table-head")
    tableHeaderRow.append($("<th></th>").addClass("outputs-column column learning-outcome").text("Learning Outcomes"))
    tableHeaderRow.append($("<th></th>").addClass("description-column column").text("Description"))
    tableHeaderRow.append($("<th></th>").addClass("outputs-column column output-column").text("Outputs"))
    tableHeaderRow.append($("<th></th>").addClass("due-date-column column").text("Due Date"))
    tableHeaderRow.append($("<th></th>").addClass("action-column column").text("Action"))
    tableHeaderRow.append($("<th></th>").addClass("lfa-column column").text("LFA Feedback"))
    return tableHeaderRow

  fetchDueDate: () =>
    if @phases
      for phase in @phases
        return phase.due_date if phase.id is @currentPhaseId

  activateOutputSubmission: () =>
    $(".enter-submission-btn").on("click", (event) =>
      @phaseName = $('.phase-item.active').text()
      @assessmentName = $(event.currentTarget).parent().siblings(":first").text()
      assessmentId = parseInt($(event.currentTarget).attr("id").split("-")[2])
      unless assessmentId is @assessmentSubmitId
        document.getElementById("learner-submission-form").reset()
      @assessmentSubmitId = assessmentId
      @loaderUI.show()
      @api
        .fetchAssessmentsPhases(@assessmentSubmitId, @currentPhaseId)
        .done((response) =>
            @targetIsMultiple = response.is_multiple
            @loaderUI.hide()
            @configureMultipleSubmissions(response, event)
        )
    )

  configureMultipleSubmissions: (response, event) ->
      unless @targetIsMultiple
        $(".field-required").trigger("keyup")
        @modal.open()
        @configureSingleSubmission(event)
        @toggleConfiguredSubmissionTypes(event)
        return $('.multiple-output-bar').hide()
      @submissionPhasesDetails = response.submission_phases
      @populateMultipleSubmissions(response)

  configureSingleSubmission: (event) ->
    @submissionMap ?= {}
    @submissionPhasesMap ?= {}

    yieldSubmissionData = =>
      data = @submissionData || @defaultSubmissionData
      data['submitted'] = !!(@outputsSubmitted && @outputsSubmitted.length)
      data = Object.assign({}, data, { day: 1, index: 0, id: @submissionData.id, identifier: '1-1', position: 1 })
      return data

    submissionData = yieldSubmissionData()
    @submissionMap[1] = { '1-1': submissionData }
    symbol = @yieldUpdatedElements()
    @submissionPhasesMap[1] = [symbol]
    @insertElementsIntoDom()
    @rehydrateFormValues(1, null, submissionData, '1-1')
    @submissionData = @cleanUpSubmissionData(submissionData)


  populateSubmissionsTopBar: (response) ->
    navigatorHtml = Object.keys(response.submission_phases).map((item) ->
      "<li class='multiple-output-item' data-day='#{item}'><a>Day #{item}</a></li>"
    )
    @cleanUpAndInsert('.multiple-output-bar', navigatorHtml.join(''))
    $('.multiple-output-bar').show()
    @modal.open()
    $('.multiple-output-item:visible').first().addClass('active')

  populateMultipleSubmissions: (response) ->
    @populateSubmissionsTopBar(response)
    generateFormElements = (targets, index, day) =>
       @submissionMap = {} unless @submissionMap?
       @submissionMap[day] = {} unless @submissionMap[day]?
       identifier = "#{targets.id}-#{targets.position}"
       unless @submissionMap[day][identifier]?
        @submissionMap[day][identifier] = { link: "", file: "", description: "" }
       symbol = @yieldUpdatedElements(day, identifier, index)
       @submissionPhasesMap[day] = [] unless @submissionPhasesMap[day]?
       @submissionPhasesMap[day].push(symbol)

    for submissionPhase in Object.entries(response.submission_phases)
      do (submissionPhase) ->
        [day, phases] = submissionPhase
        generateFormElements(phase, index, day) for phase, index in phases
    @insertElementsIntoDom()
    @registerListenersForTabs()

  cleanUpAndInsert: (symbol, elements) ->
    $(symbol).html('')
    $(symbol).html(elements)

  isValidSubType: -> @submissionTypes && @permittedTypes.includes(@submissionTypes)

  cleanUpSubmissionData: (entry) ->
    { link, description,  file, submitted, index, id } = entry
    unless @isValidSubType() then return { description, submitted, index, id }
    if @submissionTypes is "file, link" then return entry
    submission = { description, submitted, index, id }
    if @submissionTypes is 'file'
        fileDetails = { file_name: entry.file_name, file_link: entry.file_link }
        submission = Object.assign({}, submission, fileDetails) if submitted
    submission[@submissionTypes] = entry[@submissionTypes] if entry[@submissionTypes]?
    return submission

  yieldUpdatedElements: (day = 1, identifier = '1-1' , index) ->
      fingerprint = @submissionMap[day][identifier]
      symbol = " <label id='label-link' for='link' class='label-link submission-for-link'>
              Enter a link<span id='link-required' class='error-mode required-symbol link-required'>*</span>
            </label>
            <input data-day='#{day}' value='#{fingerprint.link}' data-index='#{index}' data-identifier='#{identifier}' id='link' type='text' name='link' class='field-required submission-for-link' maxlength='200' placeholder='http:// or https://'>
            <label for='fileUpload' id='file-upload-area' class='file-upload submission-for-upload'>
            <div class='drop-area submission-for-upload'>
              <label for='fileUpload' class='drop-area-text'>
                <img src='/assets/upload-icon.svg' class='upload-icon' />
                <strong>click to upload</strong> or drop your file here
              </label>
              <input type='file' data-index='#{index}' data-day='#{day}' value='#{fingerprint.file}' data-identifier='#{identifier}' id='fileUpload' class='field-required fileUpload' name='file' accept=''.png, .jpg, .jpeg' />
            </div>
            <p id='file_error' class='error file_error submission-for-upload'></p>
            </label>
            <p class='uploaded-file hidden'>
              <img src='/assets/file-icon.svg' class='uploaded-file-icon' />
              <span class='uploaded-file-name' data-index='#{index}' data-identifier='#{identifier}' ></span>

              <a class='file-link remove-file'data-day='#{day}' data-index='#{index}' data-identifier='#{identifier}' >Remove</a>
            </p>
            <label id='abel-description' for='description'>
              Enter a description<span id='description-required' class='error-mode required-symbol'>*</span>
            </label>
            <textarea data-day='#{day}' data-index='#{index}' data-identifier='#{identifier}' value='#{fingerprint.description}' id='description' type='text' name='description' class='field-required' maxlength='200'></textarea>
            "
      return symbol

  insertElementsIntoDom: (selectedDay = 1, index = 0) ->
        elementsToBeInserted = @submissionPhasesMap[parseInt(selectedDay)][index]
        @cleanUpAndInsert('#learner-submission-form', elementsToBeInserted)
        if @submissionPhasesDetails
          @submissionTypes = @submissionPhasesDetails[parseInt(selectedDay)][index].file_type
          @rehydrateFormValues(selectedDay, index)
          @toggleConfiguredSubmissionTypes()
        @clearFilesubmit()

  rehydrateFormValues: (day, index, target, identifier) ->
      target =  @submissionPhasesDetails[day][index] unless target
      identifier = "#{target.id}-#{target.position}" unless identifier
      { link, file, description, submitted } = @submissionMap[day][identifier]
      @changeHeaderTextAndButtonForModal(submitted)
      @submissionData = @cleanUpSubmissionData(@submissionMap[day][identifier])
      @submissionData.fingerprint = identifier
      $('#link:visible').val(link)
      file && $('#fileUpload:visible').val(file.filename)
      $('#description:visible').val(description)

  changeHeaderTextAndButtonForModal: (submitted) ->
    unless submitted
      $('.learner-submission-header:visible').html('Enter Submission')
      $('.phase-name').html("#{@phaseName  }")
      $('.assessment-name').html("#{@assessmentName}")
      $('#save-learner-submission').html('Save')
      $('#save-learner-submission').off 'click'
      $('#save-learner-submission').removeClass('update-submission-btn').addClass('save-output-btn')
      return @registerSaveButtonListener()
    $('.learner-submission-header:visible').html('Update Submission')
    $('.phase-name').html("#{@phaseName}")
    $('.assessment-name').html("#{@assessmentName}")
    $('#save-learner-submission').html('Update')
    $('#save-learner-submission').off 'click'
    $('#save-learner-submission').removeClass('save-output-btn').addClass('update-submission-btn')
    @registerUpdateButtonListener()

  registerListenersForTabs: ->
      $('.multiple-output-bar li a').click (e) =>
        target = $(e.currentTarget).parent()
        $(target).siblings().removeClass('active')
        $(target).addClass('active')
        selectedDay = $(target).data('day')
        @insertElementsIntoDom(selectedDay)

  toggleConfiguredSubmissionTypes: (event) =>
    { submitted } = @submissionData
    unless @targetIsMultiple
      @submissionTypes = JSON.parse($(event.currentTarget).data("sub-types"))
    # Any set of functions that you want to be called
    # anytime you switch tabs (Day 1, Day 2) can be invoked
    # here. PLUS: these functions are also invoked whenever the
    # view submission or enter submission button is clicked.
    @setModalListeners()
    @extendSubmissionModal(@submissionTypes, submitted)
    @checkForLateSubmission()
    @flushAllRequiredFields()
    if submitted then return @viewSubmittedSubmissions(@submissionTypes)
    unless @isValidSubType()
       return @hideAllSubmissionFields()
    @showAllSubmissionFields()
    unless @submissionTypes.split(', ').length > 1
      [permittedType] = @submissionTypes.split(', ')
      return @allowOnlyPermittedType(permittedType, submitted)

  allowOnlyPermittedType: (type) ->
    if type is "file"
      @toggleClass([".label-link", "#link"], 'hidden')
      @toggleClass(['#link'], 'field-required', true)
    else if type is "link"
      @toggleClass(['.label-link', '.link-required', '#link'], 'hidden', true)
      $('#file-upload-area').addClass('hidden')
      @toggleClass(['#fileUpload'], 'field-required', true)
    else
      @hideAllSubmissionFields()
    @toggleClass(['#description'], 'field-required')

  viewSubmittedSubmissions: (type) ->
    if type is "file"
      @toggleClass([".submission-for-link", ".submission-for-upload"], 'hidden')
      @toggleClass(['.uploaded-file'], 'hidden', true)
      return @configureViewSubmittedFile()

    else if type is "link"
      @toggleClass([".submission-for-upload", ".uploaded-file", '.file_error'], "hidden")
      @toggleClass([".submission-for-link"], "hidden", true)

    else
      $(".file_error").addClass('hidden')
      target = [".uploaded-file", ".submission-for-upload",  ".submission-for-link"]
      if type is 'file, link'
        @toggleClass(target, 'hidden', true)
        return @configureViewSubmittedFile()
      @toggleClass(target, 'hidden')

  configureViewSubmittedFile: () ->
    $('.uploaded-file-name').html(@submissionData.file_name)
    $('.uploaded-file-name').on 'click', (e) =>
        window.open(@submissionData.file_link, '_blank')

  showAllSubmissionFields: () ->
    @toggleClass(['#link', '#file-upload-area', '.label-link'], 'hidden', true)
    @toggleClass(['.link-required'], 'hidden')
    @toggleClass(['#link', '#fileUpload'], 'field-required')

  flushAllRequiredFields: ->
    $('.learner-submission-form > .field-required').each( (i, symbol) ->
        $(symbol).removeClass('field-required')
        $(symbol).change( ->
          $(symbol).addClass('field-required')
        )
    )

  setModalListeners: ->
    selectors = "
                  .learner-submission-form > input, .learner-submission-form > textarea,
                  .learner-submission-form > .file-upload > div > input
                  "
    $(selectors).each((i, symbol) =>
      $(symbol).change (e) =>
          day = parseInt($(symbol).data('day'))
          identifier = $(symbol).data('identifier')
          index = parseInt($(symbol).data('index'))
          if $(e.currentTarget).hasClass('fileUpload')
            @setUploadedFile(e)
            #take a snapshot and replace it on the DOM
            if @targetIsMultiple
              @submissionPhasesMap[day][index] = $('.learner-submission-form:visible').html()
          name = $(symbol).attr('name')
          unless @targetIsMultiple
            return @submissionData["#{name}"] = $(symbol).val()
          @submissionMap[day][identifier][name] = e.currentTarget.value
          @submissionData = @cleanUpSubmissionData(@submissionMap[day][identifier])
          @submissionData.fingerprint = identifier
    )

  hideAllSubmissionFields: () ->
    $('#link').addClass('hidden')
    $('.label-link').addClass('hidden')
    $('#file-upload-area').addClass('hidden')
    @toggleClass(['#link', '#fileUpload'], 'field-required', true)

  toggleClass: (nodes, className, remove) ->
    nodes.forEach (identifier) ->
      if remove
        $("#{identifier}").removeClass(className)
      else
        $("#{identifier}").addClass(className)

  extendSubmissionModal: (submissionTypes, isSubmitted) ->
    self = @
    [submissionModal] = Array.from(document.getElementsByClassName('ui-dialog'))
    extendDescriptionInput = (extend) ->
      changeDescriptionDimensions = (args) ->
         $('.submission-description').css(args)
      if extend
        isSubmitted && changeDescriptionDimensions({ 'height': '12rem', 'width': '29rem' })
        return changeDescriptionDimensions({ 'height': '10rem', 'width': '100%' })
      changeDescriptionDimensions({ 'height': '5rem', 'width': '100%' })

    isValidSubmission = ->
      return submissionTypes && self.permittedTypes.includes(submissionTypes)

    extendOutputsWithoutTypes = (valid) ->
      if valid then return submissionModal.classList.remove('dynamic-submission-modal')
      submissionModal.classList.add('dynamic-submission-modal')

    if submissionModal
        @currentInterval && clearInterval(@currentInterval)
        extendOutputsWithoutTypes(isValidSubmission())
        extendDescriptionInput(!isValidSubmission())
    else
       @currentInterval = setInterval ->
                    self.extendSubmissionModal(submissionTypes)
               , 10

  generateButtons: (buttonClass, text, data = "") =>
    if !!data
      $("<button></button>").addClass(buttonClass).attr("data-#{data.type}", data.value).html("<span class='button-text'>#{text}</span>")
    else
      $("<button></button>").addClass(buttonClass).html("<span class='button-text'>#{text}</span>")

  afterFeedbackFetch: (data) =>
    @lfaFeedback = data

  populateLfaColumn: (assessment) =>
    viewButton = @generateButtons("view-lfa-btn", "View")
    viewButton.data('assessmentId', assessment.id)
    viewButton.data('phaseId', @currentPhaseId)
    unless assessment.feedback
      return $("<p></p>").text("No feedback given")
    return viewButton

  createColumnContent: (assessment, key, index) =>
    if key is "requires_submission"
      if assessment[key]
        message = "Enter Submission"
        if assessment.name == "Writing Professionally"
          submitButton = @generateButtons("enter-submission-btn multiple-output", message)
        else
          submitButton = @generateButtons("enter-submission-btn", message)
        submitButton.attr("id", "submit-for-#{assessment.id}")
        submitButton.attr("data-sub-types", JSON.stringify(assessment.submission_types))
        if assessment.submitted
          message = "View Submission"
          submitButton = @generateButtons("view-submission-btn", message)
          submitButton.attr("data-sub-types", JSON.stringify(assessment.submission_types))
          submitButton.attr("id", "submit-for-#{assessment.id}")
        return submitButton
      return $("<p></p>").addClass("requires-lfa-observation").text("Requires LFA Observation")
    if key is "due_date"
      return $("<p></p>").text(@fetchDueDate())
    if key is "lfa_feedback"
      return @populateLfaColumn(assessment)

    if key is "description"
      return @truncateText.generateContent(assessment.description, 110)
    if key is "output"
      return @truncateText.generateContent(assessment.output, 110)
    return $("<p></p>").text(assessment[key])

  createTableRow: (assessment, index) =>
    tableRow = $("<tr></tr>").addClass("table-cell")
    tableRow.append($("<td></td>").addClass("learning-outcomes-column column").append(@createColumnContent(assessment, 'name')))
    tableRow.append($("<td></td>").addClass("description-column column").append(@createColumnContent(assessment, 'description', index)))
    tableRow.append($("<td></td>").addClass("outputs-column column").append(@createColumnContent(assessment, 'output', index)))
    tableRow.append($("<td></td>").addClass("due-date-column column").append(@createColumnContent(assessment, 'due_date')))
    tableRow.append($("<td></td>").addClass("action-column column").append(@createColumnContent(assessment, 'requires_submission')))
    tableRow.append($("<td></td>").addClass("lfa-column column").append(@createColumnContent(assessment, 'lfa_feedback')))

  generateAssessmentRow: (assessment, index) =>
    frameworkElement = document.getElementById("framework-accordion-#{assessment.framework_id}")
    frameworkTableElement = frameworkElement.querySelector(".output-table")
    unless frameworkTableElement
      frameworkTableElement = $("<table></table>").addClass("output-table")
      frameworkTableElement.append(@createTableHead())
      $(frameworkElement).append(frameworkTableElement)
    $(frameworkTableElement).append(@createTableRow(assessment, index))
    @currentAssessmentId = assessment.id

  populateOutcomesTable: (phase) =>
    return if phase.nil?
    @currentPhaseId = phase.id
    for assessment, index in phase.assessments
      @generateAssessmentRow(assessment, index)
    @clickViewSubmit()
    @activateOutputSubmission()
    @truncateText.activateShowMore()

  afterPhasesFetch: (phases) =>
    @phases = phases
    @populatePhasesBar()
    @populateOutcomesTable(@phases[0])
    $(".phases-tab").removeClass('hidden')
    @loaderUI.hide()
    @learnerFeedbackView.start()

  checkForLateSubmission: () =>
    clearLateNotification = ->
      $('.lfa-view-late-submission').html("")
      return $('.lfa-view-late-submission').hide()

    return clearLateNotification() unless @submissionData && @submissionData.id
    value = @outputsSubmitted.find((item) => item.id == @submissionData.id)
    return clearLateNotification() unless value

    due_date = moment.utc(@fetchDueDate()).endOf('day');
    submission_date = moment.utc(value['created_at'])
    unless moment(submission_date).isSameOrBefore(due_date)
      formatted_date = submission_date.local().format("ddd MMM DD YYYY HH:mm")
      $('.lfa-view-late-submission').show()
      $('.lfa-view-late-submission').html("Submitted on: #{formatted_date} hrs (LATE)")
    else
      clearLateNotification()

  afterFetch: (event) => (assessmentId, data) =>
    @loaderUI.hide()
    @targetIsMultiple = data.is_multiple
    @modal.open()
    @submissionTypes = JSON.parse($(event.currentTarget).data('sub-types')) unless @targetIsMultiple
    @populateOutputsSubmitted(data)
    @configureMultipleSubmissions(data, event)

  populateOutputsSubmitted: (data) ->
      { outputs, is_multiple, submission_phases } = data
      @submissionMap = {} unless @submissionMap?
      @outputsSubmitted = data.outputs
      unless is_multiple
        @submissionData = Object.assign({}, outputs[0], { submitted: true })
        @submissionData['file'] = outputs[0].file_link if outputs[0].file_link
        return

      populateSubmissionData = (output, index) =>
        submissionPhases = Object.values(submission_phases).flat()
        subData = submissionPhases.find((subPhase) ->

            return subPhase.id == output.submission_phase_id
            )
        return unless subData
        { day, position, id } = subData if subData
        @submissionMap[day] = {} unless @submissionMap[day]?
        @submissionMap[day]["#{id}-#{position}"] =
            {
              file: output.file_link,
              file_name: output.file_name,
              file_link: output.file_link,
              link: output.link,
              description: output.description,
              submitted: true,
              index,
              id: output.id
            }

      populateSubmissionData output, index for output, index in outputs

  hasMadeNewChanges: ->
    return !Object.keys(@submissionData).every((key) =>
        { index } = @submissionData
        return @outputsSubmitted[index][key] == @submissionData[key]
    )

  registerUpdateButtonListener: ->
    $(".update-submission-btn").click (event) =>
        event.stopImmediatePropagation()
        return @modal.close() && @flushAllValuesAfterModalIsClosed() unless @hasMadeNewChanges()
        if @validateOutput()
          $("#submit-loader-modal").removeClass("hidden")
          @updateOutput(@gatherOutputDetails(), @afterUpdate)

  registerSaveButtonListener: ->
    $(".save-output-btn").click (event) =>
      if @validateOutput()
        $("#submit-loader-modal").removeClass("hidden")
        @submitOutput(@gatherOutputDetails(), @afterSubmit)

  clickViewSubmit: =>
    $(".view-submission-btn").click (event) =>
      @phaseName = $('.phase-item.active').text()
      @assessmentName = $(event.currentTarget).parent().siblings(":first").text()
      @initialState()
      $(".drop-area").hide()
      $(".uploaded-file").show()
      @loaderUI.show()
      assessmentId = parseInt($(event.currentTarget).attr("id").split("-")[2])
      @assessmentSubmitId = assessmentId
      @setDropedFile()
      @setUploadedFile()
      @clearFilesubmit()
      @fetchOutput(assessmentId, @afterFetch(event), @currentPhaseId)
      @registerUpdateButtonListener()

    $("#close-submission-modal, #cancel-submission-modal").click (event) =>
      @modal.close()
      @flushAllValuesAfterModalIsClosed()

  #this might be deprecated with this PR
  assignDefaultSubmissionData: (submission) =>
      @submissionData.description = submission.description
      return unless @submissionTypes
      @submissionData[@submissionTypes] = submission[@submissionTypes] || submission['file_link']
      if Object.keys(@submissionData).includes('file, link')
        #the learner must have submitted either a file or link
        #so we check which one is present and assign it to submissiondata
        #that is used for validation
        delete @submissionData['file, link']
        @submissionData['link'] = submission['link'] if submission['link'] && submission['link'].length
        @submissionData['file'] = submission['file_link'] if submission['file_link'] && submission['file_link'].length

  flushAllValuesAfterModalIsClosed: ->
    document.getElementById("learner-submission-form").reset()
    @submissionData = {}
    @submissionPhasesDetails = null
    @submissionTypes = null
    @submissionMap = null
    @submissionPhases = null
    @submissionPhasesMap = {}
    @assessmentId = null
    @assessmentSubmitId = null
    @outputsSubmitted = null
    @targetIsMultiple = false
    @filesUploadedMap = {}
