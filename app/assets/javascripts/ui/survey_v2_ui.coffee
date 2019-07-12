class SurveyV2.UI
  constructor: (@api)->
    @selectQuestionOptions = [
      { key: '', text: 'Select Question Type', },
      { key: 'multiple-choices', text: 'Multiple Choices', icon: 'multiple-choice-icon', },
      { key: 'checkboxes', text: 'Checkboxes', icon: 'checkboxes-icon', },
      { key: 'dropdown', text: 'Dropdown', icon: 'dropdown-icon', },
      { key: 'scale', text: 'Scale', icon: 'scale-icon', },
      { key: 'multi-choice-grid', text: 'Multi choice Grid', icon: 'multi-choice-grid-icon', },
      { key: 'checkbox-grid', text: 'Checkbox Grid', icon: 'checkbox-grid-icon', },
      { key: 'date', text: 'Date', icon: 'datepicker-icon' },
      { key: 'time', text: 'Time', icon: 'clock-icon' },
      { key: 'paragraph', text: 'Paragraph', icon: 'paragraph-icon' },
      { key: 'picture-options', text: 'Picture Options', icon: 'picture-icon', },
      { key: 'picture-checkbox', text: 'Picture Checkbox', icon: 'picture-icon', }
    ]
    @questions = []
    @typeFormat = {
      "multiple-choices": "SurveyMultipleChoiceQuestion",
      "checkboxes": "SurveyCheckboxQuestion",
      "paragraph": "SurveyParagraphQuestion",
      "date": "SurveyDateQuestion",
      "time": "SurveyTimeQuestion",
      "dropdown": "SurveySelectQuestion",
      "scale": "SurveyScaleQuestion",
      "multi-choice-grid": "SurveyMultigridOptionQuestion",
      "checkbox-grid": "SurveyMultigridCheckboxQuestion",
      "picture-checkbox": "SurveyPictureCheckboxQuestion",
      "picture-options": "SurveyPictureOptionQuestion",
    }

    @survey = {}
    @selectedType = ''
    @sectionsCount = 0
    @sectionsId = 0
    @questionsCount = 0
    @recipients = []
    @survey_options = []
    @survey_recipients = []
    @hasLinkModalHandlers = false
    @sectionOptionLinks = {}
    @currentPreviewSection = 1
    @surveyShareModal = new Modal.App('#main-share-modal', 636, 636, 467, 467)
    @deleteSurveyModal = new Modal.App('#confirm-survey-delete-modal', 500, 500, 467, 467)
    @deleteSectionModal = new Modal.App('#confirm-section-delete-modal', 500, 500, 467, 467)
    @deleteLinkQuestionModal = new Modal.App('#confirm-link-question-delete-modal', 500, 500, 467, 467)
    @deleteLinkSectionModal = new Modal.App('#confirm-link-section-delete-modal', 500, 500, 467, 467)
    @surveyPreviewModal = new Modal.App('#survey-v2-preview-modal', 672, 672, 598, 598)
    @linkSectionToQuestionModal = new Modal.App('#section-question-link-modal', 670, 700, 600, 600)
    @surveyDeleteModal = new Modal.App('#confirm-handle-survey-delete-modal', 500, 500, 467, 467)
    @surveyEditModal = new Modal.App('#confirm-handle-survey-edit-modal', 500, 500, 467, 467)
    @chart = new ChartJs.UI()
    @title = ''
    @survey_collaborators = []
    @getAllAdmin
    @collaborators = []


  initializeCreateForm: ->
    # order matters...
    @onToggleSurveyDescription()
    @populateSelectQuestions()
    @updateSlider()
    @updateCheckBoxOnClick()
    @activateTitleHandler()
    @onAddQuestion()
    @onAddSection()
    if pageUrl[2] == 'setup'
      @addQuestion()
    @onPreviewNextClick()
    @onPreviewPreviousClick()
    @onToggleSurveyViews()
    @onCloseWindow()

  initializeShareModal: ->
    @openSurveyShareModal()
    @openSurveyDeleteModal()
    @toggleMailShare()
    @setActiveIcon('mail-icon')
    @toggleLinkShare()
    @toggleCycleDropDown()
    @toggleCollaboratorDropDown()
    @onShareSurvey()
    @onUpdateSurvey()
    @toggleDateTimePicker()
    @saveSurveyProgress()

  initializeSurveyDeleteModal: =>
    @handleSurveyDeleteModal()

  initializeSurveyEditModal: =>
    @handleSurveyEditModal()

  initializeSurveyFullScreen: ->
    @onTogglePreview()
    @onKeyPress()
    @onChangeWindowSize()

  initializeResponseModal: ->
    @openSurveyResponseModal()

  initializeEditForm: ->
    @onEditSurvey()
    @toggleButtons()

  initializeDatePicker: ->
    @onToggleSelectDate()

  initializePreviewModal: ->
    $('#select-question-arrow').selectmenu()

  onCloseWindow: ->
    if pageUrl[2] == "setup"
      window.onbeforeunload = (->
        return ' '
      )

  minimizeSurvey: ->
    @show [
      ".header-container", '#maximize',
      ".mdl-mini-footer", ".header-container-on-mobile-view",
    ]
    $(".setup-container").css(height: '65vh')
    $(".setup-container.form").css(height: '0%')
    $(".setup-container.preview").css(height: '0%')
    $("#minimize").addClass("hidden")
    @closeFullscreen()

  maximizeSurvey: ->
    @hide [
      ".header-container", ".mdl-mini-footer",
      ".header-container-on-mobile-view"
    ]
    $(".setup-container").css(height: '183%')
    $("#survey-preview--content").css(height: '52vh')
    $(".survey-v2-content").css('margin-top', '0.5em')
    @openFullscreen()

  hidePreview: ->
    $("#toggleSurvey").hide()
    $("#untoggle").removeClass("hidden")
    $(".setup-container.form").css(width: '100%')
    $('.preview')[0].style.setProperty("display", "none", "important")

  showPreview: ->
    $("#toggleSurvey").show()
    $("#untoggle").addClass("hidden")
    $(".setup-container.form").removeClass('setup-form')
    $(".preview").show()
    $(".setup-container.form").css(width: '47%')

  onChangeWindowSize: ->
    self = @
    $('#maximize').on 'click', ->
      self.maximizeSurvey()
    $('#minimize').on 'click', ->
      self.minimizeSurvey()

  onTogglePreview: ->
    self = @
    $('#toggleSurvey').on 'click', ->
      self.hidePreview()
    $("#untoggle").on 'click', ->
      self.showPreview()


  openFullscreen: ->
    element = document.body
    if element.requestFullscreen
      element.requestFullscreen()
    else if element.mozRequestFullScreen
      element.mozRequestFullScreen()
    else if element.webkitRequestFullscreen
      element.webkitRequestFullscreen()
    else if element.msRequestFullscreen
      element.msRequestFullscreen()


  closeFullscreen: ->
    if document.exitFullscreen
      document.exitFullscreen()
    else if document.mozCancelFullScreen
      document.mozCancelFullScreen()
    else if document.webkitExitFullscreen
      document.webkitExitFullscreen()
    else if document.msExitFullscreen
      document.msExitFullscreen()

  onKeyPress: =>
    self = @
    $(document).on('fullscreenchange webkitfullscreenchange mozfullscreenchange msfullscreenchange', (e) -> (
      fullscreenElement = document.fullscreenElement || document.webkitFullscreenElement || document.mozFullscreenElement || document.msFullscreenElement;
      if not fullscreenElement
        self.minimizeSurvey()
        $(".setup-container.form").css(margin: '0 0.75rem')
        $(".survey-v2-content").css(margin: '8.5em 0 0 1.5em')
      else
        $("#maximize").hide()
        $("#minimize").removeClass("hidden")
    ));

  windowResize: ->
    self = @
    $(window).on 'resize', (e) ->
      self.windowSize()

  windowSize: ->
    self = @
    if $(window).width() < 1024
      @hide [
        "#maximize", "#toggleSurvey"
      ]
    else
      @show [
        "#maximize", "#toggleSurvey",
        "#minimize", "#untoggle"
      ]
      $(".setup-container.form").addClass('setup-form')


  onToggleSurveyDescription: ->
    $('#add-survey-description-btn').on 'click', ->
      $('.survey-description-content').show()
      $('#add-survey-description-btn').hide()

  onToggleSurveyViews: ->
    $('#form-btn').addClass('button-background-color').click(->
      $('.form').show()
      $('.preview').hide()
    )

    $('#preview-btn').click( ->
      $('.form').hide()
      $('.preview').show()
    )

    $('.view-btn-1').click(->
      $(this).addClass('button-background-color').siblings().removeClass('button-background-color')
    )

  onToggleSurveyDescription: ->
    $('#add-survey-description-btn').on 'click', ->
      $('.survey-description-content').show()
      $('#add-survey-description-btn').hide()

  onToggleSelectDate: ->
    @questions.forEach (question) ->
      if question.selected_type == "date"
        $("#{question.name_space}-select-date").on 'click', ->
          $("#{question.name_space}-calendar").datetimepicker()
          $("#{question.name_space}-calendar").show()
    $(document).on 'click', (e) ->
      if (not $(e.target).is('.select-date')) and (not $(e.target).is('.ui-datepicker-prev')) and (not $(e.target).is('.ui-datepicker-next'))
        $('.calendar-item').hide()

  onToggleSurveyDescription: ->
    $('#add-survey-description-btn').on 'click', =>
      @show ['.survey-description-content']
      @hide ['#add-survey-description-btn']

    $('.description-toggle').on 'click', =>
      @hide ['.survey-description-content']
      @show ['#add-survey-description-btn']
      $('#survey-description').val ''
      @updatePreview()

  onToggleQuestionDescription: ->
    uniqueId = @questionsCount
    $("#question-#{uniqueId} .toggle-question-description").on 'click', =>
      @show ["#question-#{uniqueId} .question-description-options"]
      @hide ["#question-#{uniqueId} .toggle-question-description"]

    self = @
    ['text', 'image', 'video'].forEach((type) ->
      $("#question-#{uniqueId} .#{type}-description-option").on 'click', =>
        self.hide ["#question-#{uniqueId} .question-description-options"]
        self.show ["#question-#{uniqueId} .#{type}-description-content"]

      $("#question-#{uniqueId} .#{type}-description-content .close").on 'click', =>
        self.show ["#question-#{uniqueId} .toggle-question-description"]
        self.hide ["#question-#{uniqueId} .#{type}-description-content"]
        $("#question-#{uniqueId} #question-description").val ''
        self.updatePreview()
    )

  onToggleSelectQuestion: ->
    $(document).off 'click'
    $(document).on 'click', (e) ->
      if (not $(e.target).is('.options-wrapper'))
        $('.options-wrapper').hide()

    self = @
    uniqueId = @questionsCount
    $("#question-#{uniqueId} .select-shelter").on 'click', (e) ->
      e.stopPropagation()
      question = self.questions.find((question) ->
        question.name_space == "#question-#{uniqueId}"
      )
      self.removeQuestionDescription(question)
      if $(this).find('.options-wrapper').css('display') is 'none'
        $(this).find('.options-wrapper').show()
      else
        $(this).find('.options-wrapper').hide()

    self = @
    $("#question-#{uniqueId} .options-list .option").on 'click', ->
      questionType = $(this).find('input[type="hidden"]').val()
      self.updateBuilderType "#question-#{uniqueId}", questionType
      self.setCurrentView(uniqueId, questionType)

  removeQuestionDescription: (question) ->
      return unless question
      if $("#{question.name_space} .image-description").hide()
          $("#image-description-#{question.name_space.substr(1)}").hide()
          delete question['description']
          delete question['description_type']
      if $("#{question.name_space} .video-description").hide()
          $("#video-description-#{question.name_space.substr(1)}").hide()
          delete question['description']
          delete question['description_type']

  multipleChoices: (uniqueId) ->
    $(".question-body").addClass('enabled').attr('disabled', false)
    @show [
      "#question-#{uniqueId} .multiple-choice-answers",
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId} .add-choice",
      '#multiple-choice-questions', '.survey-title',
      '.button-wrapper-section', '.btn-survey-share',
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div",
      "#question-#{uniqueId} .checkbox-picture-answers",
      "#question-#{uniqueId} .option-picture-answers"
    ]


  checkBoxes: (uniqueId) ->
    $(".question-body").addClass('enabled').attr('disabled', false)
    @show [
      "#question-#{uniqueId} .checkbox-answers",
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId} .add-choice", '.multi-answers'
      '#checkbox-questions', '.survey-title',
      '.button-wrapper-section', '.btn-survey-share',
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div"
      "#question-#{uniqueId} .checkbox-picture-answers",
      "#question-#{uniqueId} .option-picture-answers"
    ]


  dropDown: (uniqueId) ->
    @hide ['#dropdown-questions', "#question-#{uniqueId} .main-slider-div"
      "#question-#{uniqueId} .checkbox-picture-answers",
      "#question-#{uniqueId} .option-picture-answers"
    ]
    @show [
      '.button-wrapper-section', '.btn-survey-share', '.survey-title',
      "#question-#{uniqueId} .add-choice",
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId} .dropdown-choice-answers",
      '.button-wrapper-section', '.btn-survey-share',
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]

  scale: (uniqueId) ->
    @hide ['#scale-questions']
    @show [
      "#question-#{uniqueId} .main-slider-div",
      "#question-#{uniqueId} .toggle-question-description",
      '.button-wrapper-section', '.btn-survey-share',
      '.survey-title', '#questions-preview-wrapper',
      '.btn-survey-save-progress'
    ]

  multiChoiceGrid: (uniqueId) ->
    $("#question-#{uniqueId} .question-body").addClass('enabled')
    $("#question-#{uniqueId} .question-body").attr('disabled', false)
    @show [
      "#question-#{uniqueId} .multi-choice-grid-answers",
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId}  #multi-choice-grid-questions",
      '.survey-title', '.button-wrapper-section', '.btn-survey-share'
      "#question-#{uniqueId} .row-addon",
      "#question-#{uniqueId} .column-addon"
      "#question-#{uniqueId} .multi-choice-column",
      "#question-#{uniqueId} .multi-choice-row",
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]
    @hide ['.survey-title-photo', "#question-#{uniqueId} .main-slider-div"
      "#question-#{uniqueId} .checkbox-picture-answers",
      "#question-#{uniqueId} .option-picture-answers"
    ]

  checkBoxGrid: (uniqueId) ->
    $("#question-#{uniqueId} .question-body").addClass('enabled')
    $("#question-#{uniqueId} .question-body").attr('disabled', false)
    @show [
      "#question-#{uniqueId} .checkbox-grid-answers",
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId}  #checkbox-grid-questions",'.btn-survey-share',
      '.survey-title', '.button-wrapper-section',
      "#question-#{uniqueId} .row-addon",
      "#question-#{uniqueId} .column-addon"
      "#question-#{uniqueId} .add-column",
      "#question-#{uniqueId} .add-option-row",
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]
    @hide [
      "#question-#{uniqueId} .checkbox-picture-answers",
      "#question-#{uniqueId} .option-picture-answers"
      "#question-#{uniqueId} .add-choice", '.survey-title-photo',
      "#question-#{uniqueId} .multi-choice-column",
      "#question-#{uniqueId} .multi-choice-row",
      "#question-#{uniqueId} .main-slider-div"
    ]

  date: (uniqueId) ->
    $("#question-#{uniqueId} .question-body").addClass('enabled')
    $("#question-#{uniqueId} .question-body").attr('disabled', false)
    @show [
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId} .date-input",
      "#question-#{uniqueId} .calendar",
      '.select-date', '.survey-title',
      '.button-wrapper-section', '.btn-survey-share',
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div"]
    $("#question-#{uniqueId} .cal").datepicker({dateFormat: 'dd M yy'})

  paragraph: (uniqueId) ->
    $("#question-#{uniqueId} .question-body").addClass('enabled')
    $("#question-#{uniqueId} .question-body").attr('disabled', false)
    @show [
      '.toggle-question-description', "#question-#{uniqueId} .paragraph",
      '.survey-title', '.button-wrapper-section', '.btn-survey-share',
      '#questions-preview-wrapper', '.btn-survey-save-progress'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div"]

  time: (uniqueId) ->
    $("#question-#{uniqueId} .question-body").addClass('enabled')
    $("#question-#{uniqueId} .question-body").attr('disabled', false)
    @show [
      "#question-#{uniqueId} .toggle-question-description",
      "#question-#{uniqueId} .time", '.survey-title',
      "#question-#{uniqueId} .time-input", '.btn-survey-share',
      '.button-wrapper-section', '#questions-preview-wrapper',
      '.btn-survey-save-progress'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div"]

  pictureOptions: (uniqueId) ->
    $("#question-#{uniqueId} .question-body").addClass('enabled')
    $("#question-#{uniqueId} .question-body").attr('disabled', false)
    @show [
      "#question-#{uniqueId} .option-picture-answers"
      "#question-#{uniqueId} .picture-uploads", '.answer',
      '.toggle-question-description',
      "#question-#{uniqueId} #photo-option-questions",
      '.survey-title', '.button-wrapper-section',
      '.btn-survey-share', '#questions-preview-wrapper',
      '.btn-survey-save-progress'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div"
      "#question-#{uniqueId} .checkbox-picture-answers",
    ]

  pictureCheckbox: (uniqueId) ->
    $('.question-body').addClass('enabled')
    $('.question-body').attr('disabled', false)
    @show [
      "#question-#{uniqueId} .checkbox-picture-answers",
      "#question-#{uniqueId} .picture-uploads", '.answer',
      '.toggle-question-description',
      "#question-#{uniqueId} #photo-checkbox-questions",
      '.survey-title', '.button-wrapper-section',
      '.btn-survey-share', '#questions-preview-wrapper'
    ]
    @hide ["#question-#{uniqueId} .main-slider-div"
      "#question-#{uniqueId} .option-picture-answers"
    ]

  setCurrentView: (uniqueId, questionType) ->
    @resetView(uniqueId)
    switch questionType
      when "multiple-choices" then @multipleChoices(uniqueId)
      when "checkboxes" then @checkBoxes(uniqueId)
      when "dropdown" then @dropDown(uniqueId)
      when "scale" then @scale(uniqueId)
      when "multi-choice-grid" then @multiChoiceGrid(uniqueId)
      when "checkbox-grid" then @checkBoxGrid(uniqueId)
      when "date" then @date(uniqueId)
      when "paragraph" then @paragraph(uniqueId)
      when "time" then @time(uniqueId)
      when "picture-options" then @pictureOptions(uniqueId)
      when "picture-checkbox" then @pictureCheckbox(uniqueId)
      else
        if @questions.length < 2
          @show ['.preview-content']
          @hide ['.survey-title', '#questions-preview-wrapper', ".row-addon", ".column-addon", ]

    selectedOption = @selectQuestionOptions.find(
      (option) -> option.key is questionType
    )

    $("#question-#{uniqueId} .select-question").html(
      if selectedOption.icon
        "<p class='with-icon'>#{selectedOption.text}</p>
        <span class='option-icon #{selectedOption.icon}'></span>
        <span class='down-arrow'></span>"
      else
        "<p>#{selectedOption.text}</p>
        <span class='down-arrow'></span>"
    )

  populateSelectQuestions: ->
    options = ''
    @selectQuestionOptions.forEach((option) ->
      options +=
        if option.icon
          "<div class='option'>
              <span class='option-icon #{option.icon}'></span>
              <p class='with-icon'>#{option.text}</p>
              <input type='hidden' value='#{option.key}' />
            </div>"
        else
          "<div id=\"reset_selection\" class='option'>
              <p>#{option.text}</p>
              <input type='hidden' value='#{option.key}' />
            </div>"
    )
    $('.options-list').html(options)

  resetView: (uniqueId) ->
    @hide [
      "#question-#{uniqueId} .add-choice",
      "#question-#{uniqueId} .row-addon",
      "#question-#{uniqueId} .column-addon",
      "#question-#{uniqueId} .multiple-choice-answers",
      "#question-#{uniqueId} .dropdown-choice-answers",
      "#question-#{uniqueId} .add-description-question",
      "#question-#{uniqueId} .image-description-content",
      "#question-#{uniqueId} .text-description-content",
      "#question-#{uniqueId} .video-description-content",
      "#question-#{uniqueId} .checkbox-answers",
      "#question-#{uniqueId} .image-description",
      ".video-description",
      ".preview-content", "#multiple-choice-questions",
      "#question-#{uniqueId} .video-description",
      "#multiple-choice-questions",
      "#question-#{uniqueId} #checkbox-questions",
      "#question-#{uniqueId} .survey-title",
      "#question-#{uniqueId} .button-wrapper-section",
      "#question-#{uniqueId} .btn-survey-share",
      "#question-#{uniqueId} #dropdown-questions",
      "#question-#{uniqueId} #scale-questions",
      "#question-#{uniqueId} .main-slider.div",
      "#question-#{uniqueId} .scale2",
      '.add-column', '.add-option-row',
      '.multi-choice-row', '.multi-choice-column',
      "#question-#{uniqueId} .multi-choice-grid-answers",
      "#question-#{uniqueId} .checkbox-grid-answers",
      '#multi-choice-grid-questions', '#checkbox-grid-questions',
      "#question-#{uniqueId} .picture-uploads", '.option-photo',
      '.checkbox-photo', '#photo-questions', '#photo-option-questions',
      '#photo-checkbox-questions', '.add-option', '.calendar',
      '.paragraph', "#question-#{uniqueId} .date-input",
      "#question-#{uniqueId} .time",
      "#question-#{uniqueId} .time-input",
      '.btn-survey-save-progress'
    ]
    $('.calendar-item').datetimepicker('destroy')

  hide: (handles) ->
    handles.map (handle) ->
      $(handle).hide()

  show: (handles) ->
    handles.map (handle) ->
      $(handle).show()

  toggleSwitchButton: () =>
    uniqueId = @questionsCount
    @show ["#question-#{uniqueId} .not-required"]
    @hide ["#question-#{uniqueId} .required"]
    $("#question-#{uniqueId} .mdl-switch__input").on 'click', =>
      $("#question-#{uniqueId} .mdl-switch").toggleClass('is-checked')
      if($("#question-#{uniqueId} .mdl-switch")).hasClass('is-checked')
        @show ["#question-#{uniqueId} .required"]
        @hide ["#question-#{uniqueId} .not-required"]
      else
        @show ["#question-#{uniqueId} .not-required"]
        @hide ["#question-#{uniqueId} .required"]
      setTimeout (=>
        @updatePreview()
      ), 0

  toggleQuestionDropdown: () =>
    uniqueId = @questionsCount
    @hide [
      "#question-#{uniqueId} .main-slider-div",
      'dropdown-choice-answers', '.scale2'
    ]
    @show ['.blank']
    selectElement = $("#question-#{uniqueId} .select-question")
    selectElement.change ->
      @show ['#' + $(this).val()]
      if $(this).val() is 'Scale'
        @show [".main-slider-div #question-#{uniqueId}"]
      else
        @hide [".main-slider-div #question-#{uniqueId}"]

  updateSlider: () =>
    uniqueId = @questionsCount
    $("#question-#{uniqueId} .mdl-slider").on 'change', ->
      fraction = (this.value - this.min) / (this.max - this.min)
      $("#question-#{uniqueId} .slider-message").html(this.value)
      $("#question-#{uniqueId} .mdl-slider__background-lower").css("flex", "#{fraction} 1 0%")
      $("#question-#{uniqueId} .mdl-slider__background-upper").css("flex", "#{1-fraction} 1 0%")

  updateCheckBoxOnClick: () =>
    uniqueId = @questionsCount
    $("#question-#{uniqueId} .slider-checkbox").on 'change', (event) ->
      # order matters...
      $(this).toggleClass('is-checked')
      value = if $(this).hasClass('is-checked') then 0 else 1
      $("#question-#{uniqueId} .mdl-slider").attr('min', value)
      $("#question-#{uniqueId} .mdl-slider").val(value)
      $("#question-#{uniqueId} .slider-message").html(value)
      $("#question-#{uniqueId} .mdl-slider__background-lower").css("flex", "0 1 0%")
      $("#question-#{uniqueId} .mdl-slider__background-upper").css("flex", "1 1 0%")

   openSurveyShareModal: ->
    @setShareTitle(@title)
    $('#survey-share-btn').on 'click', =>
      if @validateSurvey()
        @getSurveyRecipients()
        @getSurveyCollaborators()
        $('#mail-share').click()
        @surveyShareModal.open()
    $('.btn-survey-update').on 'click', =>
      if @validateSurvey()
        @getSurveyRecipients()
        @getSurveyCollaborators()
        $('#mail-share').click()
        @surveyShareModal.open()
    $('#close-share-modal').on 'click', =>
      @surveyShareModal.close()

  setShareTitle: (title) ->
    $('.strong-text').html('').append """<span>#{title}</span>"""

  handleSurveyDeleteModal: ->
    self = @
    $(".survey-card .delete").each((index, element) ->
      $(element).on 'click', =>
        id = $(this).data('survey_id')
        return unless Number.isInteger(id)
        self.surveyDeleteModal.open()
        $('#confirm-handle-survey').off('click').on 'click', ->
          self.api.deleteSurveys(id, (error) -> (
            error = if error.responseJSON then error.responseJSON.message else {}
            errorMessage = if error then error else "An error occurred while processing the data"
            self.flashErrorMessage errorMessage
            self.surveyDeleteModal.close()
          )).then((data) -> (
            self.flashSuccessMessage data.message
            setTimeout (=>
              window.location.href = '/surveys-v2'
            ), 300
          ))
    )
    $('.close-handle-survey').add('#confirm-handle-survey-delete-modal .close-button').on 'click', =>
      self.surveyDeleteModal.close()

  handleSurveyEditModal: ->
    self = @
    $(".survey-card .edit").each((index, element) ->
      $(element).on 'click', =>
        id = $(this).data('survey_id')
        return unless Number.isInteger(id)
        self.surveyEditModal.open()
        $('#confirm-handle-edit-survey').on 'click', ->
          self.api.editSurvey(id, (error) -> (
            error = if error.responseJSON then error.responseJSON.message else {}
            errorMessage = if error then error else "An error occurred while processing the data"
            self.flashErrorMessage errorMessage
            self.surveyEditModal.close()
          )).then((data) -> (
            window.location.href = '/surveys-v2/' + data.id + '/edit'
          ))
    )
    $('.close-handle-edit-survey').add('#confirm-handle-survey-edit-modal .close-button').on 'click', =>
      self.surveyEditModal.close()

  saveSurveyProgress: ->
    self = @
    $('#survey-save-progress').on 'click', =>
      if pageUrl[2] == 'setup'
        status = $("#survey-save-progress").val().trim()
        survey = self.getSurvey(status)
        return unless survey
        if @validateSurvey()
          self.api.saveSurvey(
            survey,
            (response) -> (
              error = if response.responseJSON then response.responseJSON.error else {}
              errorMessage =
                if error.survey
                  error.survey.message
                else if error.survey_question
                  "Question #{error.survey_question.position}: #{error.survey_question.message}"
                else
                  "An error occured."
              self.flashErrorMessage errorMessage
            )
          ).then(
            (response) -> (
              self.flashSuccessMessage response.message
              window.onbeforeunload = null
              setTimeout (=>
                window.location.href = '/surveys-v2'
              ), 500
            )
          )
      else if pageUrl[3] == 'edit'
        survey = self.getSurvey('draft')
        if @validateSurvey()
          self.api.updateSurvey(
            survey,
            (response) -> (
              error = if response.responseJSON then response.responseJSON.error else {}
              errorMessage =
                if error.survey
                  error.survey.message
                else if error.survey_question
                  "Question #{error.survey_question.position}: #{error.survey_question.message}"
                else
                  "An error occured."
              self.flashErrorMessage errorMessage
              self.surveyShareModal.close()
              $('.update-btn-shelter').removeClass('disabled')
            )
          ).then(
            (response) -> (
              self.flashSuccessMessage response.message
              setTimeout (=>
                window.location.href = '/surveys-v2'
              ), 500
            )
          )


  toggleDateTimePicker: ->
    pickerOptions = {
      controlType: 'select',
      oneLine: true,
      stepMinute: 5,
      dateFormat: 'dd M yy',
      timeFormat: 'HH:mm',
      minDate: moment().format('DD MMM YYYY HH:mm')
    }

    $("#survey_share_start_date").change ->
      $("#survey_share_end_date").datetimepicker( "destroy" )
      $("#survey_share_end_date").datetimepicker(
        Object.assign({}, pickerOptions, {minDate: $(this).val()})
      )

    $("#survey_share_end_date").change ->
      $("#survey_share_start_date").datetimepicker( "destroy" )
      $("#survey_share_start_date").datetimepicker(
        Object.assign({}, pickerOptions, {maxDate: $(this).val()})
      )

  openSurveyDeleteModal: ->
    $('.close-delete-modal, .submit-delete-modal').on 'click', =>
      @deleteSurveyModal.close()
      @deleteSectionModal.close()
      @deleteLinkQuestionModal.close()
      @deleteLinkSectionModal.close()

  toggleCycleDropDown: ->
    $('html').on 'click', (e) =>
      if (not $(e.target).is('.cycle-options-wrapper'))
        @hide ['.cycle-options-wrapper']
    $('.select-cycle').on 'click', (e) =>
      e.stopPropagation()
      if $('.cycle-options-wrapper').css('display') is 'none'
        @show ['.cycle-options-wrapper']
      else
        @hide ['.cycle-options-wrapper']
    $('.cycle-options-list .option').on 'click', =>
      cycle = $(this).find('p').text()
      $('.select-cycle').html "<p>#{cycle}</p><span class='down-arrow'></span>"

  toggleCollaboratorDropDown: ->
    $('html').on 'click', (e) =>
      if (not $(e.target).is('.collaborator-options-wrapper'))
        @hide ['.collaborator-options-wrapper']
    $('.select-collaborators').on 'click', (e) =>
      e.stopPropagation()
      if $('.collaborator-options-wrapper').css('display') is 'none'
        @show ['.collaborator-options-wrapper']
      else
        @hide ['.collaborator-options-wrapper']
    $('.collaborator-options-list .collaborators-option').on 'click', =>
      collaborator = $(this).find('p').text()
      $('.select-collaborators').html "<p>#{collaborator}</p><span class='down-arrow'></span>"

  onShareSurvey: ->
    self = @
    $('#main-share-modal .send-button').on 'click', =>
      return if $('.send-btn-shelter').hasClass('disabled')
      survey_status = $(".send-btn-shelter").attr('name')
      survey = self.getSurvey(survey_status)
      return unless survey
      $('.send-btn-shelter').addClass('disabled')
      self.api.saveSurvey(
        survey,
        (response) -> (
          error = if response.responseJSON then response.responseJSON.error else {}
          errorMessage =
            if error.survey
              error.survey.message
            else if error.survey_question
              "Question #{error.survey_question.position}: #{error.survey_question.message}"
            else
              "An error occured."
          self.flashErrorMessage errorMessage
          self.surveyShareModal.close()
          $('.send-btn-shelter').removeClass('disabled')
        )
      ).then(
        (response) -> (
          self.flashSuccessMessage response.message
          window.onbeforeunload = null
          setTimeout (=>
            window.location.href = '/surveys-v2'
          ), 500
        )
      )

  getSurveyRecipients: () =>
    self = @
    @api.getActiveCycles(self.flashErrorMessage)
      .then((data) -> (
        self.recipients = data.recipients
        self.populateRecipients()
      ))

  getSurveyCollaborators: () =>
    @api.getAllAdmin().then((response) =>
      @collaborators = response.emails
      @getCollaborators()
    )
  populateRecipients: () =>
    self = @
    options = ''
    @recipients.forEach((option) ->
      already_selected = self.survey_recipients.find((recipient) ->
        recipient.cycle_center_id == option.cycle_center_id
      )
      return if already_selected
      options += """
        <div class='option'>
          <p>#{option.name} -- #{option.cycle}</p>
          <input type='hidden' value='#{option.cycle_center_id}'/>
        </div>"""
    )
    $('.cycle-options-list').html(options)

    $('#main-share-modal .option').on 'click', -> (
      selected_id = $(this).find('input').val()
      selected_recipient = self.recipients.find((recipient) ->
        recipient.cycle_center_id == selected_id
      )
      self.survey_recipients.push(selected_recipient)
      options = ''
      self.survey_recipients.forEach((recipient) -> (
        options += """
          <li>
            #{recipient.name} #{recipient.cycle}
            <span data-target="#{recipient.cycle_center_id}" class="close">&times;</span>
          </li>
        """
      ))
      $('#main-share-modal .selected-cycles').html(options)
      $('#main-share-modal .selected-cycles .close').on 'click', -> (
        remove_id = $(this).data('target')
        self.survey_recipients =
          self.survey_recipients.filter((recipient) -> recipient.cycle_center_id != remove_id)
        $(this).parent().remove()
        self.populateRecipients()
      )
      self.populateRecipients()
    )

  toggleMailShare: ->
    self = @
    $('#mail-share').on 'click', ->
      self.registerActiveClass 'mail-share'
      $('.select-collaborators-description').html 'Invite collaborators'
      $('.select-recipients-description').html 'Select Recipients'
      $('#copy').hide()
      $('#copy-learner-link').hide()
      self.show [
        '.checkbox-div',
        '.share-date-content',
        '.share-submit-container',
        '.select-recipients.bootcampers'
      ]
      self.setActiveIcon 'mail-icon'
      self.showSelectField()

  toggleLinkShare: ->
    self = @
    $('.copy-survey-link').on 'click', ->
      $('.embed-link-input').select()
      document.execCommand('copy')
      self.flashSuccessMessage "Successfully copied"
    $('.copy-learner-link').on 'click', ->
      $('.embed-learner-link-input').select()
      document.execCommand('copy')
      self.flashSuccessMessage "Successfully copied"
    $('#link-share').on 'click', ->
      self.registerActiveClass 'link-share'
      self.hide [
        '.checkbox-div',
        '.share-date-content',
        '.share-submit-container'
      ]
      self.setActiveIcon 'sharelink-icon'
      programId = localStorage.getItem('programId')
      href = window.location.href + "?programId=#{programId}"
      learnerLink = window.location.origin + "/#{pageUrl[1]}/respond/#{pageUrl[2]}" + "?programId=#{programId}"
      if href.indexOf('edit') == -1
        $('.select-collaborators-description').html '<center>Kindly save the survey to get it\'s link.</center>'
        self.hideInputField()
      else
        $('.select-collaborators-description').html 'Collaborator\'s link'
        $('.select-recipients-description').html 'Learner\'s link'
        $('#copy').show()
        $('#copy-learner-link').show()
        self.setPlaceholder 'embed-link-input', '<iframe>video url</iframe>'
        self.setPlaceholder 'embed-learner-link-input', '<iframe>video url</iframe>'
        self.showInputField()
        $('.embed-link-input').val(href)
        $('.embed-learner-link-input').val(learnerLink)

  registerActiveClass: (elem) ->
    $("##{elem}").addClass('is-active')
    ['link-share', 'mail-share', 'frame-share'].filter((icon) ->
      icon != elem
    ).map((icon) ->
      $("##{icon}").removeClass('is-active')
    )

  setActiveIcon: (elem) ->
    $("##{elem}-active").show()
    $("##{elem}").hide()
    ['sharelink-icon', 'mail-icon', 'embed-icon'].filter((icon) ->
      icon != elem
    ).map((icon) ->
      $("##{icon}-active").hide()
      $("##{icon}").show()
    )

  setPlaceholder: (elem, holder) ->
    $("##{elem}").attr 'placeholder', holder

  hideInputField: ->
    $('.input-shelter').hide()
    $('.select-shelter').hide()
    $('.selected-cycles').hide()

  showInputField: ->
    $('.input-shelter').show()
    $('.select-shelter').hide()
    $('.selected-cycles').hide()

  showSelectField: ->
    $('.input-shelter').hide()
    $('.select-shelter').show()
    $('.selected-cycles').show()

  validateSurvey: ->
    self = @
    validity = true
    error_message = ''
    title = $('#survey-2-title').val().trim()
    @setShareTitle(title)
    @title = title
    description = $("#survey-description").val().trim()
    if title == ''
      validity = false
      error_message = 'Please, enter a title for your survey. '
      self.flashErrorMessage error_message
    @questions.map (question) ->
      question_number = $("#{question.name_space}").find(".active-question-no span").text()
      if !($("#{question.name_space} #question-body").val().trim())
        error_message = "Question #{question_number} cannot be empty. "
        validity = false
        self.flashErrorMessage error_message

      if !question.selected_type
        validity = false
        error_message = "Question #{question_number} must have a type."
        self.flashErrorMessage error_message
      switch question.selected_type
        when 'multiple-choices', 'checkboxes', 'dropdown', 'picture-checkbox', 'picture-options'
          if question.survey_options.length < 2
            validity = false
            error_message = "Question #{question_number} must contain at least two (2) options."
            self.flashErrorMessage error_message
        when 'scale'
          if not question.scale or question.scale.min >= question.scale.max
            validity = false
            error_message = "Scale question #{question_number} must have valid min and max values."
            self.flashErrorMessage error_message
        when 'multi-choice-grid', 'checkbox-grid'
          if question.survey_options.rows.length < 2
            validity = false
            error_message = "Question #{question_number} must contain at least two (2) rows."
            self.flashErrorMessage error_message
          if question.survey_options.columns.length < 2
            validity = false
            error_message = "Question #{question_number} must contain at least two (2) columns."
            self.flashErrorMessage error_message

    return validity

  mapType: (type) ->
    @typeFormat[type]

  getSurveySectionLinks: ->
    links = {}
    for sectionId, linkInfo of @sectionOptionLinks
      linked_section = $("##{sectionId}")
      linked_section_num = linked_section.index(".cloned-section") + 1
      linked_section_title = "Section #{linked_section_num}"

      section_number = $("##{linkInfo.section_id}").index(".cloned-section") + 1
      question_number = $("##{linkInfo.question_id}").index(".cloned, .cloned-linked") + 1
      option_number = $("##{linkInfo.question_id} ##{linkInfo.option_id}").index('.answer') + 1

      links[linked_section_title] = {
        section_number, question_number, option_number
      }
    return links
  unMapType: (type) ->
    for key, value of @typeFormat
      if value == type
        return key

  getSurvey: (status) ->
    self = @
    files = []
    survey = {}
    survey_questions = @questions

    survey_questions = survey_questions.map (question, index) ->
      survey_question = {
        section: question.section,
        position: index + 1,
        question: question.question,
        question: $("#{question.name_space} #question-body").val().trim(),
        is_required: $("#{question.name_space} .mdl-switch").hasClass('is-checked'),
        type: self.mapType(question.selected_type),
        description: question.description,
        description_type: question.description_type
      }

      switch question.description_type
        when 'image', 'video'
          if typeof question.description == 'object'
            file_key = "file_#{Object.keys(files).length + 1}"
            files[file_key] = question.description
            survey_question.description = file_key

      switch question.selected_type
        when 'multiple-choices', 'checkboxes', 'dropdown'
          survey_question.survey_options = question.survey_options.map (option, index) ->
            option.position = index + 1
            option
        when 'multi-choice-grid', 'checkbox-grid'
          survey_question.survey_options = question.survey_options
        when 'picture-checkbox', 'picture-options'
          survey_question.survey_options =
            question.survey_options.map (option) ->
              if option.survey_option_question_id
                return option
              else
                file_key = "file_#{Object.keys(files).length + 1}"
                files[file_key] = option.option
                { option: file_key, option_type: 'image', position: index + 1 }
        when 'scale'
          survey_question.scale = question.scale
        when 'date'
          survey_question.date_limits = question.date_limits
      return survey_question

    edit_response = if $("#edit_responses").hasClass('is-checked') then true else false
    survey_id = ''
    if pageUrl[3] == "edit"
      survey_id = pageUrl[2]

    end_date = $("#survey_share_end_date").val().trim()
    start_date = $("#survey_share_start_date").val().trim()
    unless end_date and start_date
      self.flashErrorMessage 'Please provide the start and end date'
      return
    if self.survey_recipients.length < 1 && status == 'published'
      self.flashErrorMessage 'Please select recipients for the survey'
      return
    if pageUrl[2] == "setup" && moment().startOf('day').diff(moment(start_date).startOf('day'), 'day') > 0
      self.flashErrorMessage "Start date must not be behind the present date"
      return
    if new Date(start_date) >= new Date(end_date)
      self.flashErrorMessage "End date must be ahead of start date"
      return

    survey = {
      title: $('#survey-2-title').val().trim()
      description: $("#survey-description").val().trim()
      status: status
      recipients: self.survey_recipients.map((recipient) -> recipient.cycle_center_id),
      edit_response: edit_response
      survey_id: survey_id
      end_date
      start_date
      survey_questions
      survey_section_links: self.getSurveySectionLinks()
    }
    survey.collaborators = self.survey_collaborators
    survey.program_id = localStorage.getItem('programId')
    form = new FormData()
    form.append('survey', JSON.stringify(survey))
    for key, value of files
      form.append(key, value)
    return form

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')

  activateTitleHandler: ->
    $('#survey-2-title, #survey-description').keyup (event) =>
      @updatePreview()

  activateKeyHandler: (target = "#question-0", section, duplicate=null) ->
    if duplicate
      details = @getQuestionDetails(duplicate)
      details.name_space = target
      @questions.push details
    else
      @questions.push {
        name_space: target,
        section,
        selected_type: '',
        question: '',
      }

    self = @
    $("#{target} #question-body").keyup (event) =>
      self.questions.map (question) ->
        if question.name_space == target
          question.question = event.target.value.trim()

    $("#{target} #add-choice").keyup (event) =>
      if event.which == 13 and event.target.value.trim()
        self.questions.map((question) ->
          if question.name_space == target
            question.survey_options.push {
              option: event.target.value,
              id: question.survey_options.length
            }
        )
        self.renderOptions(target)
        event.target.value = ''

    $("#{target} #column-addon").keyup (event) =>
      if event.which == 13 and event.target.value.trim()
        @questions.map((question) ->
          if question.name_space == target
            if !question.survey_options
              question.survey_options = { rows: [], columns: [] }

            unless question.survey_options.columns.length < 7
              self.flashErrorMessage 'You cannot have more than 7 columns'
            else
              question.survey_options.columns.push {
                option: event.target.value,
                id: question.survey_options.columns.length + 1,
                position: question.survey_options.columns.length
              }
        )
        self.renderOptions(target)
        event.target.value = ''

    $("#{target} .min-date").change (event) ->
      self.setDateLimits(event, 'min', target)

    $("#{target} .max-date").change (event) ->
      self.setDateLimits(event, 'max', target)
      

    $("#{target} #row-addon").keyup (event) =>
      if event.which == 13 and event.target.value.trim()
        @questions.map((question) ->
          if question.name_space == target
            if !question.survey_options
              question.survey_options = { rows: [], columns: [] }
            question.survey_options.rows.push {
              option: event.target.value,
              id: question.survey_options.rows.length + 1,
              position: question.survey_options.rows.length
            }
        )
        self.renderOptions(target)
        event.target.value = ''

    $("#{target} .mdl-slider, #{target} .slider-checkbox").on 'change', ->
      self.questions.map((question) ->
        if question.name_space == target
          delete question['survey_options']
          question.scale = {
            min: if $(target).find('.slider-checkbox').hasClass('is-checked') then 0 else 1,
            max: parseInt($("#{target} .mdl-slider").val())
          }
      )
      self.renderOptions(target)

    $("#add-file-#{target.substr(1)}").on 'change', (event) =>
      self.questions.map((question) ->
        if question.name_space == target
          question.survey_options.push {
            option_type: 'image',
            option: event.target.files[0],
            id: question.survey_options.length
          }
      )
      $("#add-file-#{target.substr(1)}")[0].value=''
      self.renderOptions(target)
    $("#add-video-file-#{target.substr(1)}").on 'change', (event) =>
      self.questions.map((question) ->
        if question.name_space == target
          question.description = event.target.files[0]
          question.description_type = 'video'
      )
      $("#add-video-file-#{target.substr(1)}")[0].value=''
      self.renderOptions(target)

    $("#add-image-file-#{target.substr(1)}").on 'change', (event) =>
      self.questions.map((question) ->
        if question.name_space == target
          question.description = event.target.files[0]
          question.description_type = 'image'
      )
      $("#add-image-file-#{target.substr(1)}")[0].value=''
      self.renderOptions(target)

    $("#{target} #question-description").keyup (event) =>
      self.questions.map((question) ->
        if question.name_space == target
          question.description = event.target.value
          question.description_type = "text"
      )
      self.updatePreview()

    $('#question-body, #question-description', target).keyup (event) =>
      self.updatePreview()

  updatePreview: () =>
    if pageUrl[2] == 'setup' || pageUrl[3] == 'edit'
      survey_title = $('#survey-2-title').val().trim()
      survey_description = $('#survey-description').val().trim()
      $('#survey-preview-title').text survey_title
      $('#survey-preview-description').text survey_description
      $("#questions-preview-wrapper").html @getBuilderPreview()
      $('.survey-dropdown').selectmenu()
      $('.question ul li').on 'click', ->
        $(this).parent().find('li').removeClass('active')
        $(this).addClass('active')
      @show [ "#questions-preview-wrapper", ".survey-title", "#survey-share-btn", "#survey-save-progress"]
      if @questions.length < 1 || @getEmptySection(@questions, @currentPreviewSection)
        @show [".preview-content"]
        @hide [".list-no-hide", ".question-content"]
      else
        @hide [".preview-content"]
      @onToggleSelectDate()
      @handleSectionControl()
      @toggleButtons()
      componentHandler.upgradeDom()

  getTargetQuestionType: (target) ->
    question = @questions.find((question) -> question.name_space == target)
    return question.selected_type if question

  getEmptySection: (questions, sectionId) =>
    currentSection = questions.filter (question) -> question.section == sectionId
    return false if currentSection.length > 1 || currentSection.length == 0
    if currentSection[0].selected_type.trim().length < 1
      return true
    return false

  getBuilderPreview: () =>
    self = @
    $(".section-preview-title span").text "section #{@currentPreviewSection}"
    @questions.map (question, index) ->
      if question.section != self.currentPreviewSection
        return false
      question_position = $("#{question.name_space}").find(".active-question-no span").text()
      title =  if pageUrl[3] != 'edit'  then question.question else $("#{question.name_space} #question-body").val().trim()
      previewBlock = ''
      required = ''
      preview_options = ''
      preview_question = """
        <div class="question-content">
          <p>
          #{title}
            #{self.getPreviewQuestionDescription(question)}
          </p>
        </div>
      """
      if question.selected_type == "checkbox-grid"
        if $("#{question.name_space} .mdl-switch").hasClass('is-checked')
          required = "<small id='toggle'><span>*</span> This question requires many responses per row</small>"
      else if question.selected_type == "multi-choice-grid"
        if $("#{question.name_space} .mdl-switch").hasClass('is-checked')
          required = "<small id='toggle'><span>*</span> This question requires one response per row</small>"
      else
        if $("#{question.name_space} .mdl-switch").hasClass('is-checked')
          required = "<small id='toggle'><span>*</span> Required</small>"


      position = question_position || question.position
      previewBlock += """
        <div class="mdl-grid mdl-grid--no-spacing question">
          <div class="mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet">
            <div class="list-no list-no-hide">#{position}</div>
          </div>
          <div class="mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet question_content">
            #{preview_question}
            #{self.getPreviewOptions(question)}
            #{required}
          </div>
        </div>
      """

  getInputBuilder: (buildType) ->
    switch buildType
      when "multiple-choices"
        type = "radio"
        option_pane = '.multiple-choice-answers'
        preview_pane = '#multiple-choice-questions'
      when "checkboxes"
        type = "checkbox"
        option_pane = '.checkbox-answers'
        preview_pane = '#checkbox-questions'
      when "dropdown"
        type = "dropdown"
        option_pane = '.dropdown-choice-answers'
        preview_page = '#dropdown-questions'
      when "scale"
        type = "scale"
        option_pane = '.scale-answers'
        preview_page = '#scale-questions'
      when "checkbox-grid"
        type = "checkbox-grid"
        option_pane = '.checkbox-grid-answers'
      when "multi-choice-grid"
        type = "multi-choice-grid"
        option_pane = '.multi-choice-grid-answers'
      when "picture-checkbox"
        type = "checkbox"
        option_pane = ".checkbox-picture-answers"
        preview_pane = "#checkbox-questions"
      when "picture-options"
        type = "radio"
        option_pane = ".option-picture-answers"
        preview_pane = "#multiple-choice-questions"
    { type, option_pane, preview_pane }

  getViewOptions: (target) ->
    self = @
    build = {}
    @questions.map (question) ->
      if question.name_space == target
        build = self.getInputBuilder question.selected_type
    build

  getSurveyOptions: (target) ->
    survey_options = []
    @questions.map (question) ->
      if question.name_space == target
        survey_options = question.survey_options
    survey_options

  renderOptions: (target) ->
    viewOptions = @getViewOptions target
    question = @questions.find((question) -> question.name_space == target)
    $("#{target} #{viewOptions.option_pane}").html @getBuilderOptions(question)
    @activateOptionRemovalEvent question
    @updatePreview()
    @setMediaDescription question

  setMediaDescription:(question, uniqueId) =>
    self = @
    if question.description_type == 'image'
      $("#{question.name_space} .image-description").show()
      $("#{question.name_space} .image-description-content").hide()
      description = $("#{question.name_space} .image-description")
      description.find('.file-image-name').html question.description.name || question.description
      description.find('.file-image-size').html if question.description.size then "[#{Math.round(question.description.size/(10240))/100}MB]" else ""
      description.find('.media-close').on 'click', (event) =>
        key = parseInt event.target.getAttribute 'key'
        self.removeQuestionDescription(question)
        @show [".toggle-question-description"]
    if question.description_type == 'video'
      $("#{question.name_space} .video-description").show()
      $("#{question.name_space} .video-description-content").hide()
      description = $("#{question.name_space} .video-description")
      description.find('.file-video-name').html question.description.name || question.description
      description.find('.file-video-size').html if question.description.size then "[#{Math.round(question.description.size/(10240))/100}MB]" else ""
      description.find('.media-close').on 'click', (event) =>
        key = parseInt event.target.getAttribute 'key'
        self.removeQuestionDescription(question)
        @show [".toggle-question-description"]

  getBuilderOptions: (question) ->
    self = @
    builder_options = ""
    switch (question.selected_type)
      when 'multiple-choices'
        question.survey_options.map (item) ->
          builder_options += """
            <div class="survey-item-container">
              <div class="answer" id="answer-#{item.id}">
                <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                <input disabled type="radio" name="option"/><span class="item-option">#{item.option}</span>
                <div class="custom-radio"></div>
              </div>
            </div>
          """
      when 'checkboxes'
        question.survey_options.map (item) ->
          builder_options += """
            <div class="survey-item-container">
              <div class="answer" id="answer-#{item.id}">
                <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                <input disabled type="checkbox" name="option"/><span class="item-option">#{item.option}</span>
                <div class="custom-checkbox"></div>
              </div>
            </div>
          """
      when 'dropdown'
        question.survey_options.map (item, index) ->
          builder_options += """
            <div class="survey-item-container">
              <div class="answer" id="answer-#{item.id}">
                <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                <span class="option-number">#{index + 1}.</span>
                <span class="option-text">#{item.option}</span>
              </div>
            </div>
          """
      when 'checkbox-grid'
        rows = question.survey_options.rows
        cols = question.survey_options.columns
        builder_options = "<div class='table-responsive'><table class='table table-borderless checkbox-grid-table'>"
        for i in [0...Math.max(rows.length, cols.length)]
          row_content =
            if i < rows.length then """
                <td class="table-width rows">
                  <span class='option-numbers'>#{i+1}. </span>
                  <span class="item-option">#{rows[i].option}</span>
                  <div key="#{rows[i].id}" class='close'></div>
                </td>
              """
            else
              """<td class="table-width"></td>"""
          col_content =
            if i < cols.length then """
                <td class="table-width columns">
                  <input disabled type='checkbox' />
                  <span class="item-option">#{cols[i].option}</span>
                  <div key="#{cols[i].id}" class='close'></div>
                </td>
              """
            else
              ""
          builder_options += """
            <tr>
              #{row_content}
              #{col_content}
            </tr>
          """
        builder_options += "</table></div>"
      when 'multi-choice-grid'
        rows = question.survey_options.rows
        cols = question.survey_options.columns
        builder_options = "<div class='table-responsive'><table class='table table-borderless checkbox-grid-table'>"
        for i in [0...Math.max(rows.length, cols.length)]
          row_content =
            if i < rows.length then """
                <td class="table-width rows">
                  <span class='option-numbers'>#{i+1}. </span>
                   <span class="item-option">#{rows[i].option}</span>
                  <div key="#{rows[i].id}" class='close'></div>
                </td>
              """
            else
              """<td class="table-width"></td>"""
          col_content =
            if i < cols.length then """
                <td class="table-width columns">
                  <input disabled type='radio' />
                  <span class="item-option">#{cols[i].option}</span>
                  <div key="#{cols[i].id}" class='close'></div>
                </td>
              """
            else
              ""
          builder_options += """
            <tr>
              #{row_content}
              #{col_content}
            </tr>
          """
        builder_options += "</table></div>"
      when 'picture-checkbox'
        question.survey_options.map (item) ->
          if item.survey_option_question_id
            resource = self.processMediaLink(item.option)
            base_name = resource.base_name
            extension = resource.extension
            builder_options += """
              <div class="survey-item-container">
                <div class="answer photo-uploads" id="answer-#{item.id}">
                  <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                    <div class="photo-size">
                      <span class="file-name">#{base_name}.#{extension}</span>
                    </div>
                </div>
              </div>
            """
          else
            builder_options += """
              <div class="survey-item-container">
                <div class="answer photo-uploads" id="answer-#{item.id}">
                  <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                    <div class="photo-size">
                      <span class="file-name">#{item.option.name}</span>
                      <span class="file-size">[#{Math.round(item.option.size/(10240))/100}MB]</span>
                    </div>
                </div>
              </div>
            """
      when 'picture-options'
        question.survey_options.map (item) ->
          if item.survey_option_question_id
            resource = self.processMediaLink(item.option)
            base_name = resource.base_name
            extension = resource.extension
            builder_options += """
              <div class="survey-item-container">
                <div class="answer photo-uploads" id="answer-#{item.id}">
                  <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                    <div class="photo-size">
                      <span class="file-name">#{base_name}.#{extension}</span>
                    </div>
                </div>
              </div>
            """
          else
            builder_options += """
              <div class="survey-item-container">
                <div class="answer photo-uploads" id="answer-#{item.id}">
                  <div key="#{item.id}" id="close-#{item.id}" class="close"></div>
                    <div class="photo-size">
                      <span class="file-name">#{item.option.name}</span>
                      <span class="file-size">[#{Math.round(item.option.size/(10240))/100}MB]</span>
                    </div>
                </div>
              </div>
            """
    return builder_options

  getPreviewOptions: (question) ->
    self = @
    preview_options = ''
    switch question.selected_type
      when 'multiple-choices'
        question.survey_options.map (item) ->
          preview_options += """
            <div class="answer">
              <input type="radio" name="option"/>
                <span class=item-option>#{item.option}</span>
              <div class="custom-radio"></div>
            </div>
          """
      when 'checkboxes'
        question.survey_options.map (item) ->
          preview_options += """
            <div class="answer">
              <input type="checkbox" name="option"/>
                <span class=item-option>#{item.option}</span>
              <div class="custom-checkbox"></div>
            </div>
          """
      when 'dropdown'
        if question.survey_options.length
          preview_options = """
            <select class='survey-dropdown'>
              <option>Select</option>
          """
          question.survey_options.map (item) ->
            preview_options +=  """
                <option>#{item.option}</option>
          """
          preview_options += "</select>"
      when 'scale'
        [min, max] = [1, 3]
        if question.scale
          min = question.scale.min
          max = question.scale.max
        preview_options += "<ul>"
        for index in [min..max]
          preview_options += "<li class='scale'>#{index}</li>"
        preview_options += "</ul>"
      when 'paragraph'
        preview_options = """
          <div class="paragraph-wrapper">
            <div class="mdl-grid mdl-grid--no-spacing paragraph-txt">
              <div class="mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet">
              </div>
              <div class="mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet">
                <textarea type="text" id="text-box" class="txt" rows="7" cols="39"></textarea>
              </div>
            </div>
          </div>
        """
      when 'date'
        preview_options = """
          <div class="calendar-wrapper">
            <div class="mdl-grid mdl-grid--no-spacing date">
              <div class="mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet">
              </div>
              <div class="mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet">
                <div class="survey-item-container">
                  <input class="select-date cal" id="#{question.name_space.substr(1)}-select-date" type="text" placeholder="Select Date"/>
                  <div id="#{question.name_space.substr(1)}-calendar" class="calendar-item"></div>
                </div>
              </div>
            </div>
          </div>
        """
      when 'time'
        preview_options = """
          <div class="time-wrapper">
            <div class="mdl-grid mdl-grid--no-spacing date">
              <div class="mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet">
              </div>
              <div class="mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet">
                <div class="main-display">
                <input class="display-time" type="text" placeholder="01:"/>
                <input class="display-time" type="text" placeholder="01"/>
                <div class="display-time am-pm">
                  <select>
                    <option value="AM">AM</option>
                    <option value="PM">PM</option>
                  </select>
                </div>
                </div>
              </div>
          </div>
        </div>
        """
      when 'checkbox-grid'
        cols = question.survey_options.columns.map (col) ->
          "<th>#{col.option}</th>"

        survey_checkmarks = question.survey_options.columns.map (col) ->
          """<td>
              <label class='checkmark-container'>
                <input type='checkbox' name="name-#{col.id}" />
                <span class='checkmark'></span>
              </label>
          </td>"""

        rows = question.survey_options.rows.map (row) ->
          """<tr class="tr_row">
              <td>#{row.option}</td>
              #{survey_checkmarks.join('')}
            </tr>"""

        preview_options += """
        <div class="table-responsive">
          <table class="table">
            <thead>
              <th></th>
              #{cols.join('')}
            </thead>
            <tbody>
              #{rows.join('')}
            </tbody>
          </table>
        </div>
      """

      when 'multi-choice-grid'
        cols = question.survey_options.columns.map (col) ->
          "<th>#{col.option}</th>"

        survey_checkmarks = question.survey_options.columns.map (col) ->
          """<td>
              <label class='radio-container'>
                <input type='radio' name="-name-" />
                <span class='radio-mark'></span>
              </label>
          </td>"""

        rows = question.survey_options.rows.map (row, index) ->
          """<tr class="tr_row">
              <td>#{row.option}</td>
              #{survey_checkmarks.join('').replace(/-name-/g, "name-#{index}")}
            </tr>"""

        preview_options += """
          <div class="table-responsive">
            <table class="table">
              <thead>
                <th></th>
                #{cols.join('')}
              </thead>
              <tbody>
                #{rows.join('')}
              </tbody>
            </table>
          </div>
        """
      when 'picture-options'
        preview_options += "<ol>"
        question.survey_options.forEach (item, index) ->
          preview_options += """
            <li class="option-image-list-item">
              <input class="image-option" type="radio" name="selector-#{question.name_space.substr(1)}">
              <div class="custom-radio"></div>
              <img class="image-description-placeholder option-image" id="image-#{question.name_space.substr(1)}-#{index}" alt="">
              <div id="en-#{question.name_space.substr(1)}-#{index}" class="enlarge-image"></div>
            </li>
          """
          image_callback = (param, image_index) -> (
            $("#image-#{question.name_space.substr(1)}-#{image_index}")
              .attr('src', param)
              .hover(
                ->
                  $("#en-#{question.name_space.substr(1)}-#{image_index}.enlarge-image").css('opacity', '1')
                ->
                  $("#en-#{question.name_space.substr(1)}-#{image_index}.enlarge-image").css('opacity', '0')
                )
            $("#en-#{question.name_space.substr(1)}-#{image_index}").click ->
              self.showImagePreviewModal param
          )

          if item.survey_option_question_id
            resource = self.processMediaLink(item.option)
            base_name = resource.base_name
            extension = resource.extension
            media_src = "/surveys-v2/download?base_name=#{base_name}&extension=#{extension}"
            setTimeout( => image_callback(media_src, index))
          else
            self.imageToBase64(item.option, (data) -> (
              setTimeout( => image_callback("data:image/png;base64,#{data}", index))
            ))
        preview_options += "</ol>"

      when 'picture-checkbox'
        preview_options += "<ol>"
        question.survey_options.forEach (item, index) ->
          preview_options += """
            <li class="checkbox-image-list-item">
              <input class="image-checkbox" type="checkbox">
              <div class="custom-checkbox"></div>
              <img class="image-description-placeholder checkbox-image" id="image-#{question.name_space.substr(1)}-#{index}" alt="">
              <div id="en-#{question.name_space.substr(1)}-#{index}" class="enlarge-image"></div>
            </li>
          """
          image_callback = (param, image_index) -> (
            $("#image-#{question.name_space.substr(1)}-#{image_index}")
              .attr('src', param)
              .hover(
                ->
                  $("#en-#{question.name_space.substr(1)}-#{image_index}.enlarge-image").css('opacity', '1')
                ->
                  $("#en-#{question.name_space.substr(1)}-#{image_index}.enlarge-image").css('opacity', '0')
                )
            $("#en-#{question.name_space.substr(1)}-#{image_index}").click ->
              self.showImagePreviewModal param
          )

          if item.survey_option_question_id
            resource = self.processMediaLink(item.option)
            base_name = resource.base_name
            extension = resource.extension
            media_src = "/surveys-v2/download?base_name=#{base_name}&extension=#{extension}"
            setTimeout( => image_callback(media_src, index))
          else
            self.imageToBase64(item.option, (data) -> (
              setTimeout( => image_callback("data:image/png;base64,#{data}", index))
            ))
        preview_options += "</ol>"
    return preview_options

  showImagePreviewModal: (image) ->
    $('.preview-modal, .close-backdrop').css('display', 'block')
    $('#preview-content').attr('src', image)
    $('.close-modal, .close-backdrop').click () =>
      $('.preview-modal').css('display', 'none')

  getPreviewQuestionDescription: (question) ->
    return '' unless question.description
    preview_description = ''
    switch question.description_type
      when 'text'
        preview_description = """
          <span class="title-icon pull-right" id="T#{question.name_space}">
            <i class="material-icons md-18 md-dark pull-left">help_outline</i>
          </span>
          <span class="mdl-tooltip mdl-tooltip--top" for="T#{question.name_space}">
            #{question.description}
          </span>
        """
      when 'image'
        preview_description = """
        <br>
          <img class="description-answer" id="image-description-#{question.name_space.substr(1)}"/>
        """
        if typeof question.description == "object"
          @imageToBase64(question.description, (data) -> (
            $("#image-description-#{question.name_space.substr(1)}").attr('src', "data:image/png;base64,#{data}")

          ))
        else
          preview_description = """
          <br>
            <img width="400" class="description-answer" id="image-description-#{question.name_space.substr(1)}" src="#{question.description}"/>
          """

  
      when 'video'
        preview_description = """
        <br>
          <video class="description-answer" id="video-description-#{question.name_space.substr(1)}" controls width="400"/>
        """
        if typeof question.description == "object"
          @imageToBase64(question.description, (data) -> (
            $("#video-description-#{question.name_space.substr(1)}").attr('src', "data:video/mp4;base64,#{data}")
          ))
        else
          preview_description = """
          <br>
            <video class="description-answer" src="#{question.description}" id="video-description-#{question.name_space.substr(1)}" controls width="400"/>
          """

    return preview_description

  activateOptionRemovalEvent: (question) ->
    self = @
    switch question.selected_type
      when 'checkboxes', 'multiple-choices', 'dropdown', 'picture-checkbox', 'picture-options'

        question.survey_options.map (option) ->
          $("#{question.name_space} #close-#{option.id}").off()
          $("#{question.name_space} #close-#{option.id}").on 'click', (event) =>
            key = parseInt event.target.getAttribute 'key'
            self.removeOption question.name_space, key

      when 'checkbox-grid', 'multi-choice-grid'
        $('.rows').on 'click', (event) =>
          key = parseInt event.target.getAttribute 'key'
          question.survey_options.rows =
            question.survey_options.rows.filter (option) -> key != option.id
          $(".rows-#{key}").remove()
          @renderOptions(question.name_space)

        $('.columns').on 'click', (event) =>
          key = parseInt event.target.getAttribute 'key'
          question.survey_options.columns =
            question.survey_options.columns.filter (option) -> key != option.id
          $(".columns-#{key}").remove()
          @renderOptions(question.name_space)

  updateQuestionsNumbering: () =>
    i = 0
    $(".active-question-no").each( ->
      $(this).find("span").text(++i)
    )

  updateSectionNumbering: () =>
    i = 0
    $(".cloned-section").each ->
      $(this).find(".section-title .section-title-text").text "Section #{++i}"

  updateOptionNumbering: (cloned) =>
    i = 0
    cloned.find('.answer').each ->
      $(this).find(".option-number").text(++i+'.')

  updateQuestionsSectioning: () =>
    @questions.map (question) ->
      section = $(".cloned-section").index($(question.name_space).parent()) + 1
      question.section = section

  updateQuestionsAndSections: () ->
    @updateSectionNumbering()
    @updateQuestionsSectioning()
    @updateQuestionsNumbering()
    @sortQuestions()
    @updateQuestionNoReorderTooltips()
    @updatePreview()
    @hideAddSection()

  removeEmptySections: () =>
    self = @
    $(".cloned-section").each ->
      sectionId =  $(this).attr("id").split("-")[1]
      if ($(this).find(".cloned, .cloned-linked").length < 1 && sectionId != '0')
        self.removeSection($(this))
        $(".new-section-#{sectionId}").remove()

  removeOption: (name_space, key) ->
    @questions.map (question) ->
      if question.name_space == name_space
        question.survey_options = question.survey_options.filter (option) ->
          key != option.id
    @renderOptions(name_space)

  removeDescriptionOption: (question, key) ->
    key != question.name_space
    @renderOptions(name_space)

  onAddQuestion: (id) =>
    self = @
    $("#add-question-btn-#{id}").click ->
      self.addQuestion(id)
      self.updatePreview()

  onAddSection: (id) =>
    self = @
    $("#add-section-btn-#{id}").click ->
      self.addSection(true, id)

  removeSection: (section) =>
    number = +section.attr("id").split("-")[1] + 1
    if @questions.length > 0
      @questions = @questions.filter (question) -> question.section != number
    @sectionsCount = if @sectionsCount - 1 > -1 then --@sectionsCount else 0
    @currentPreviewSection = if @currentPreviewSection - 1 > 0 then --@currentPreviewSection else 1
    section.remove()
    @updateQuestionsAndSections()

  addSection: (shouldAddQuestion) ->
    newSectionId = "section-#{@sectionsId}"
    sectionNumber = ++@sectionsCount
    cloned = $(".parent-section")
      .clone()
      .removeClass("parent-section hidden")
      .addClass("cloned-section")
      .appendTo("#sortable-questions")
      .attr('id', newSectionId)
      @addEditButtons(cloned)

    cloned.find(".section-title-text").html "Section #{@sectionsCount}"
    cloned.find(".section-options").hover(
      ->
        cloned.find(".section-options .drop-options").show()
        cloned.find(".section-title").css('box-shadow', 'none')
      ->
        cloned.find(".section-options .drop-options").hide()
        cloned.find(".section-title").css('box-shadow', 'inset 0 1px 3px 0 rgba(51, 62, 68, 0.1)')
    )
    cloned.find(".section-options #re-order-up").attr("id", "re-order-up-#{newSectionId}")
    cloned.find(".section-options #re-order-down").attr("id", "re-order-down-#{newSectionId}")
    @activateSectionOptions(cloned)
    if shouldAddQuestion
      @addQuestion(@sectionsId)
    ++@sectionsId
    @updatePreview()
    @hideAddSection()

  hideAddSection: () =>
    self = @
    $(".cloned-section").each ->
      last = $(".cloned-section").last().attr("id").split("-")[1]
      sectionId = $(this).attr("id").split("-")[1]
      if sectionId != "#{last}"
        $("#add-section-btn-#{sectionId}").hide()
      $("#add-section-btn-#{last}").show()

  addEditButtons: (cloned) =>
    id = cloned.attr("id").split("-")[1]
    cloned_buttons = $(".add-question-section-buttons")
      .clone()
      .removeClass("add-question-section-buttons hidden")
      .appendTo("#sortable-questions")
    cloned_buttons.find("#add-section-btn").attr("id", "add-section-btn-#{id}")
    cloned_buttons.find("#add-question-btn").attr("id", "add-question-btn-#{id}")
    cloned_buttons.addClass("new-section-#{id}")
    @onAddQuestion(id)
    @onAddSection(id)

  activateSectionOptions: (section) ->
    self = @
    section.find(".section-options .drop-item").click (event) ->
      index = $(".cloned-section").index(section)
      shouldClose = false
      switch event.target.id
        when "re-order-up-#{section.attr('id')}"
          if section.is(".linked") || section.is(".hasLink")
            break
          if index < 1
            self.flashErrorMessage("You cannot re-order the first section up")
            break
          section.insertBefore($(".cloned-section").eq(index - 1))
          $(".new-#{section.attr('id')}").insertAfter section
          self.updateQuestionsAndSections()
        when "re-order-down-#{section.attr('id')}"
          if section.is(".linked") || section.is(".hasLink")
            break
          if index >= $(".cloned-section").length - 1
            self.flashErrorMessage("You cannot re-order the last section down")
            break
          section.insertAfter($(".new-section-#{index+1}"))
          $(".new-#{section.attr('id')}").insertAfter section
          self.updateQuestionsAndSections()
        when "link-question"
          shouldClose = true
          self.linkSectionToQuestionModal.open()
          $(".link-modal-select").selectmenu()
          self.populateLinkQuestionModal section
          $("#link-modal-close-btn").off('click').click ->
            self.linkSectionToQuestionModal.close()
        when "unlink-question"
          shouldClose = true
          self.removeLink section
          self.flashSuccessMessage "Section successfully unlinked"
        when "remove-section"
          shouldClose = true
          self.addSectionDeleteHandler(section)
        when "duplicate-section"
          shouldClose = true
          newSectionId = "section-#{self.sectionsId}"
          self.addSection(false)
          self.duplicateSection(section, newSectionId)
          $("##{newSectionId}").insertAfter section
          self.updateQuestionsAndSections()
      if shouldClose then section.find(".section-options .drop-options").hide()

  addSectionDeleteHandler: (section) ->
    self = @
    if section.is(".linked, .hasLink")
      self.deleteLinkSectionModal.open()
    else
      self.deleteSectionModal.open()
    $("#confirm-delete-section, #confirm-delete-link-section").off('click').click ->
      for sectionId, linkInfo of self.sectionOptionLinks
        if section.attr("id") == sectionId
          self.removeLink section
        else if section.attr("id") == linkInfo["section_id"]
          self.removeLink $("##{sectionId}")
      sectionId = section.attr("id").split("-")[1]
      $(".new-section-#{sectionId}").remove()
      self.removeSection(section)
      self.deleteSectionModal.close()
      self.deleteLinkSectionModal.close()

  removeLink: (section) ->
    linkInfo = @sectionOptionLinks[section.attr("id")]

    linkContainerSection = $("##{linkInfo.section_id}")
    linkContainerQuestion = $("##{linkInfo.question_id}")
    linkContainerOption = $("##{linkInfo.option_id}")

    linkContainerSection
      .removeClass("hasLink")
      .find(".section-options .sorter")
      .removeClass("linked")
    linkContainerQuestion
      .removeClass("cloned-linked")
      .addClass("cloned")
      .find(".ordering-icon").show()
    linkContainerQuestion
      .removeData("linkedTo")
      .find(".linked-icon").hide()
    linkContainerQuestion
      .find(".question-number .mdl-tooltip").remove()
    linkContainerOption
      .removeClass("hasLink")

    @removeNoReorderTooltips [section, linkContainerSection]
    section.find(".section-options #unlink-question").attr("id", "link-question").text("Link to Question")
    section.find(".section-options .sorter").removeClass("linked")
    section.removeClass("linked")
    section.find(".section-link-info").remove()
    delete @sectionOptionLinks[section.attr("id")]

  populateLinkQuestionModal: (section) ->
    self = @
    allowedQuestionTypes = ["multiple-choices", "dropdown", "picture-options"]
    self.clearLinkModalDropdowns "Select Section", "Select Section", "Select Section"
    precedingSections = self.getPrecedingSectionTitles(section).sort()
    unless precedingSections.length
      self.linkSectionToQuestionModal.close()
      self.flashErrorMessage "Oops! You need a previous section to link to"
      return false

    sectionItemToValue = (i) -> i.split(" ")[1]
    sectionItemToText = (i) -> i
    sectionOptions = self.toOptions precedingSections, sectionItemToValue, sectionItemToText, "Select Section"
    $("#section-link-dropdown").html sectionOptions
    $("#section-link-dropdown").selectmenu "refresh"

    self.activateLinkButton(section)
    if self.hasLinkModalHandlers
      return
    self.hasLinkModalHandlers = true

    questionHash = {}
    $("#section-link-dropdown").on "selectmenuchange", (event) ->
      if event.target.value < 1
        self.clearLinkModalDropdowns false, "Select Section", "Select Section"
        return
      sectionQuestions = self.questions.filter (question) -> question.section == +event.target.value &&
        question.selected_type in allowedQuestionTypes
      unless sectionQuestions.length
        self.flashErrorMessage "That section does not contain any linkable questions"
        self.clearLinkModalDropdowns false, "Select Question", "Select Question"
        return
      self.clearLinkModalDropdowns(false, null, "Select Question")
      questionHash = sectionQuestions.reduce (acc, question) ->
        acc[self.getQuestionNumber(question.name_space)] = question.name_space
        acc
      , {}
      questionItemToValue = (i) -> i
      questionItemToText = (i) -> "Question #{i}"
      questionOptions = self.toOptions(Object.keys(questionHash),
        questionItemToValue, questionItemToText, "Select Question")
      $("#question-link-dropdown").html questionOptions
      $("#question-link-dropdown").selectmenu "refresh"

    $("#question-link-dropdown").on "selectmenuchange", (event) ->
      if event.target.value < 1
        self.clearLinkModalDropdowns false, false, "Select Question"
        return
      questionOptions = self.getLinkableQuestionOptions(questionHash[event.target.value])
      unless questionOptions.length
        self.flashErrorMessage "That question does not contain any linkable options"
        self.clearLinkModalDropdowns false, false, "Select Question"
        return
      optionItemToValue = (i) -> i.split(" ")[1][0]
      optionItemToText = (i) -> i
      optionOptions = self.toOptions questionOptions, optionItemToValue, optionItemToText, "Select Option"
      $("#option-link-dropdown").html optionOptions
      $("#option-link-dropdown").selectmenu "refresh"

  activateLinkButton: (section) ->
    self = @
    $("#link-confirm-btn").off("click").click ->
      section_number = +$("#section-link-dropdown").val()
      question_number =  +$("#question-link-dropdown").val()
      option_number = +$("#option-link-dropdown").val()
      unless section_number > 0 && question_number > 0 && option_number > 0
        self.flashErrorMessage("Please select all a section, a question, and an option")
        return

      linkContainerSection = $(".cloned-section").eq(section_number - 1)
      linkContainerQuestion = $(".cloned, .cloned-linked").eq(question_number - 1)
      linkContainerOption = linkContainerQuestion.find(".answer").eq(option_number - 1)

      section.find(".section-options #link-question").attr("id", "unlink-question").text("Unlink")
      section.find(".section-options .sorter").addClass("linked")
      section.addClass("linked")
      section.find(".section-break-ctx").after(
        """
        <p class="section-link-info">
          linked to question #{$(".cloned, .cloned-linked").index(linkContainerQuestion) + 1}
        <p>
        """
      )

      linkContainerSection
        .addClass("hasLink")
        .find(".section-options .sorter").addClass("linked")
      linkContainerQuestion
        .removeClass("cloned")
        .addClass("cloned-linked")
        .find(".ordering-icon").hide()
      tooltip =
        """
        <span class="mdl-tooltip mdl-tooltip--top" for="linked-icon-#{linkContainerQuestion.attr('id')}">
          This question is linked to Section #{$(".cloned-section").index(section) + 1}. You cannot reorder it
        </span>
        """
      linkContainerQuestion
        .data("linkedTo", section.attr("id"))
        .find(".linked-icon").show()
        .after(tooltip)
      linkContainerOption
        .addClass("hasLink")

      self.addNoReorderTooltips [section, linkContainerSection]

      self.sectionOptionLinks[section.attr("id")] = {
        section_id: linkContainerSection.attr("id"),
        question_id: linkContainerQuestion.attr("id"),
        option_id: linkContainerOption.attr("id")
      }
      self.flashSuccessMessage "Section successfully linked to option"
      self.linkSectionToQuestionModal.close()

  updateQuestionNoReorderTooltips: ->
    $(".cloned-linked").each (index, question) ->
      section =  $("##{$(question).data("linkedTo")}")
      $(question).find(".question-number .mdl-tooltip").text(
        "This question is linked to Section #{$(".cloned-section").index(section) + 1}. You cannot reorder it"
      )

  addNoReorderTooltips: (sections) ->
    sections.forEach (section) ->
      section.find(".drop-options").append(
        """
        <span class="mdl-tooltip mdl-tooltip--top" for="re-order-up-#{section.attr('id')}">
          You cannot re-order a linked section
        </span>
        <span class="mdl-tooltip mdl-tooltip--top" for="re-order-down-#{section.attr('id')}">
          You cannot re-order a linked section
        </span>
        """
      )
    componentHandler.upgradeDom()

  removeNoReorderTooltips: (sections) ->
    sections.forEach (section) ->
      section.find(".drop-options span").remove()

  clearLinkModalDropdowns: (section = "Select Section", question = "Select Question", option = "Select Option") ->
    if section
      $("#section-link-dropdown").find('option').remove().end()
      $("#section-link-dropdown").html "<option value=0 selected>#{section}</option>"
      $("#section-link-dropdown").selectmenu("destroy").selectmenu({ style: "dropdown" })
    if question
      $("#question-link-dropdown").find('option').remove().end()
      $("#question-link-dropdown").html "<option value=0 selected>#{question}</option>"
      $("#question-link-dropdown").selectmenu("destroy").selectmenu({ style: "dropdown" })
    if option
      $("#option-link-dropdown").find('option').remove().end()
      $("#option-link-dropdown").html "<option value=0 selected>#{option}</option>"
      $("#option-link-dropdown").selectmenu("destroy").selectmenu({ style: "dropdown" })

  getPrecedingSectionTitles: (section) ->
    section.prevAll(".cloned-section").map(->
      $(this).find(".section-title-text").text()
    ).get()

  getQuestionNumber: (namespace) ->
    $("#{namespace} .active-question-no").find("span").text()

  getLinkableQuestionOptions: (namespace) ->
    i = 0
    $(namespace).find(".answer").get().reduce (total, value) ->
      ++i
      if $(value).is(".hasLink")
        total = total
      else
       total.push("Option #{i}: " + $(value).find("span").text())
      total
    , []

  toOptions: (array, itemToValue, itemtoText, placeholder) ->
    array.reduce (options, value) ->
      options + "<option value=#{itemToValue(value)}>#{itemtoText(value)}</option>"
    , "<option value=0 selected>#{placeholder}</option>"

  duplicateSection: (parentSection, newSectionId) =>
    self = @
    parentSection.find(".cloned, .cloned-linked").each ->
      index = self.questionsCount
      question_id = $(this).attr("id")
      self.duplicateQuestion(question_id, index, newSectionId)
      ++self.questionsCount
      @addEditButtons(cloned)

  onPreviewNextClick: () =>
    self = @
    $("#next-section").click ->
      ++self.currentPreviewSection
      self.updatePreview()

  onPreviewPreviousClick: () =>
    self = @
    $("#previous-section").click ->
      --self.currentPreviewSection
      self.updatePreview()

  handleSectionControl: () =>
    if @sectionsCount > 1
      $(".section-preview-control").css("display", "flex")
    else
      $(".section-preview-control").hide()

    if @sectionsCount == @currentPreviewSection
      $("#next-section").prop("disabled", true)
    else
      $("#next-section").prop("disabled", false)

    if @currentPreviewSection == 1
      $("#previous-section").prop("disabled", true)
    else
      $("#previous-section").prop("disabled", false)

  reorderQuestions: () =>
    self = @
    $('.ordering-icon').on 'mousedown', ->
      $(this).removeClass('survey-icon').addClass('reorder-icon')
      $(this).parents('.cloned').find('.list-no').removeClass('bg-black')
      $(this).parents('.cloned').find('.survey-container').addClass('survey-shadow')
      allSectionIds = [0...self.sectionsId].map((section) ->
        "#section-#{section}").join(", ")
      cancel = false
      $(allSectionIds).sortable(
        distance: 5
        handle: '.ordering-icon'
        items: '> .cloned'
        connectWith: allSectionIds
        beforeStop: (event, ui) ->
          if $(this).is(".linked, .hasLink") && $(this).children(".cloned, .cloned-linked").length < 1
            self.flashErrorMessage "you cannot move the last question of a linked section"
            cancel = true
        stop: ->
          if cancel
            return false
          self.handleDrop()
      )
    $('.ordering-icon').on 'mouseup', ->
      self.resetOrderIconStyle()

  reorderOptions: (cloned) =>
    self = @
    cloned.find('.answer-field').sortable(
      update: ->
        if cloned.is(".cloned-linked")
          self.flashErrorMessage "you cannot sort the options of a linked question"
          $(this).sortable "cancel"
      stop: self.optionDrop(cloned)
    )

  optionDrop: (cloned) =>
    self = @
    optionsOrder = {}
    cloned.find('.answer-field').on 'sortstop', ->
      id = cloned.attr('id')
      cloned.find('.answer').each ->
        optionIndex = $(this).parent().index()
        optionsOrder[$(this).attr('id').split("-")[1]] = optionIndex

      self.questions = self.questions.map (question) ->
        if question.name_space == '#'+ id
          question.survey_options.sort (a, b) ->
            optionsOrder[a.id] - optionsOrder[b.id]
        return question
      self.updateOptionNumbering(cloned)
      self.updatePreview()

  handleDrop: () =>
    @resetOrderIconStyle()
    @updateQuestionsNumbering()
    @updateQuestionsSectioning()
    @sortQuestions()
    @removeEmptySections()

  sortQuestions: () =>
    self = @
    sectionOrder = {}
    questionOrder = {}
    $(".cloned-section").each (section)->
      sectionIndex = $(this).index()
      $(this).find(".cloned, .cloned-linked").each ->
        questionIndex = $(this).index()
        sectionOrder['#'+$(this).attr('id')] = sectionIndex
        questionOrder['#'+$(this).attr('id')] = questionIndex

    @questions = @questions.sort (a, b) ->
      sectionOrder[a.name_space] - sectionOrder[b.name_space] ||
        questionOrder[a.name_space] - questionOrder[b.name_space]
    @updatePreview()

  resetOrderIconStyle: () =>
    self = @
    $('.ordering-icon').removeClass('reorder-icon').addClass('survey-icon')
    $('.ordering-icon').parents('.cloned').find('.list-no').addClass('bg-black')
    $('.ordering-icon').parents('.cloned').find('.survey-container').removeClass('survey-shadow')

  addQuestion: (id) =>
    self = @
    if self.sectionsCount == 0
      self.addSection(false, id=0)
    newQuestionId = "question-#{self.questionsCount}"
    cloned = $('.survey-question-body')
      .clone()
      .removeClass('survey-question-body hidden')
      .addClass('cloned')
      .appendTo("#section-#{id}")
      .attr('id', newQuestionId)
      .show()

    cloned.find(".question-no").addClass("active-question-no")
    cloned.find(".linked-icon").attr("id", "linked-icon-#{newQuestionId}")
    cloned.find("#add-file").attr("id", "add-file-#{newQuestionId}")
    cloned.find(".photo-upload label").attr("for", "add-file-#{newQuestionId}")
    cloned.find("#add-video-file").attr("id", "add-video-file-#{newQuestionId}")
    cloned.find(".video-description-content label").attr("for", "add-video-file-#{newQuestionId}")
    cloned.find("#add-image-file").attr("id", "add-image-file-#{newQuestionId}")
    cloned.find(".image-description-content label").attr("for", "add-image-file-#{newQuestionId}")

    cloned.find(".delete-question").click ->
      self.addQuestionDeleteHandler(cloned)
    cloned.find(".duplicate-question").click ->
      self.duplicateQuestion(newQuestionId, self.questionsCount)
      ++self.questionsCount

    self.onToggleSelectQuestion()
    self.onToggleQuestionDescription()
    self.toggleSwitchButton()
    self.toggleQuestionDropdown()
    self.updateSlider()
    self.updateCheckBoxOnClick()
    section = parseInt(id) + 1
    self.activateKeyHandler("##{newQuestionId}", section)
    self.updateQuestionsNumbering()
    self.reorderQuestions()
    self.reorderOptions(cloned)
    ++self.questionsCount

  addQuestionDeleteHandler: (question) ->
    self = @
    if question.is(".cloned-linked")
      self.deleteLinkQuestionModal.open()
    else
      self.deleteSurveyModal.open()
    $("#confirm-delete-survey, #confirm-delete-link-question").click ->
      index = $(".cloned, .cloned-linked").index(question)
      for sectionTitle, linkInfo of self.sectionOptionLinks
        if linkInfo["question_number"] == index + 1
          self.removeLink $(".cloned-section").eq(+sectionTitle.split(" ")[1] - 1)
      self.removeClonedBuilder(question, "##{question.attr('id')}")

  removeClonedBuilder: (clone, name_space) =>
    self = @
    clone.animate({height: '0'}, 150, -> (
      clone.remove()
      self.popNameSpace name_space
      self.removeEmptySections()
      self.updateQuestionsNumbering()
    ))

  popNameSpace: (name_space) ->
    @questions = @questions.filter((question) -> question.name_space != name_space)
    @updatePreview()

  flushOptions: (name_space) ->
    @questions.map (question) =>
      if question.name_space == name_space
        switch question.selected_type
          when 'multiple-choices', 'checkboxes', 'dropdown'
            return question.survey_options = [] if !question.survey_options?
            if question.survey_options.rows || (question.survey_options[0] && question.survey_options[0].option_type)
              question.survey_options = []
            else
              question.survey_options ?= []
          when 'picture-checkbox', 'picture-options'
             return question.survey_options = [] if !question.survey_options?
             if question.survey_options.rows || (question.survey_options[0] && !question.survey_options[0].option_type)
                question.survey_options = []
          when 'multi-choice-grid', 'checkbox-grid'
            return question.survey_options = { rows: [], columns: [] } if !question.survey_options?
            if !question.survey_options.rows
              question.survey_options = { rows: [], columns: [] }
    $("#{name_space} .multiple-choice-answers").html ''
    $("#{name_space} .checkbox-answers").html ''
    $("#{name_space} .checkbox-grid-answers").html ''
    $("#{name_space} .multi-choice-grid-answers").html ''
    $("#{name_space} .dropdown-choice-answers").html ''
    $("#{name_space} .checkbox-picture-answers").html ''
    $("#{name_space} .option-picture-answers").html ''
    @renderOptions(name_space)

  updateBuilderType: (target, type) ->
    @questions.map (question) ->
      if question.name_space == target and question.selected_type != type
        question.selected_type = type
      if type == 'scale'
        question.scale = {min: 1, max: 3}
      if type == 'date'
        question.date_limits = {} unless question.date_limits
  
    @flushOptions target

  imageToBase64: (file, callback) ->
    reader = new FileReader()
    reader.onload = (e) ->
      callback(btoa(e.target.result))
    reader.readAsBinaryString(file)

  duplicateQuestion: (questions_id, index, clonedSectionId) ->
    self = @
    duplicate = $("##{questions_id}").clone()
      .removeClass('survey-body hidden')
      .addClass('cloned')
      .attr('id', "question-#{index}")
      .show()
    duplicate.find(".question-no").addClass("active-question-no")
    duplicate.find("#add-file").attr("id", "add-file-question-#{index}")
    duplicate.find(".photo-upload label").attr("for", "add-file-question-#{index}")
    duplicate.find("#add-file-#{questions_id}").attr("id", "add-file-question-#{index}")
    duplicate.find(".delete-question").click ->
      self.addQuestionDeleteHandler(duplicate)
    duplicate.find(".duplicate-question").click ->
      self.duplicateQuestion("question-#{index}", self.questionsCount)
      ++self.questionsCount
    if clonedSectionId
      $(duplicate).appendTo $("##{clonedSectionId}")
    else
      $("##{questions_id}").after duplicate
    self.onToggleSelectQuestion()
    self.updateSlider()
    self.updateCheckBoxOnClick()
    self.onToggleQuestionDescription()
    self.toggleSwitchButton()
    self.updateQuestionsNumbering()
    self.reorderQuestions()
    self.reorderOptions(duplicate)
    self.activateKeyHandler("#question-#{index}", null, "##{questions_id}")
    self.renderOptions("#question-#{index}")
    self.sortQuestions()

  getQuestionDetails: (clone) ->
    self = @
    question_clone = {}
    @questions.map (question) ->
      if question.name_space == clone
        question_clone = self.makeCopy question
        delete question_clone.name_space
    question_clone

  makeCopy: (object) -> $.extend(true, {}, object)

  onEditSurvey: () ->
    $(".survey").addClass("active")
    self = @
    @api.editSurvey(
      pageUrl[2],
      (response) -> (
        error = if response.responseJSON then response.responseJSON.error else {}
        errorMessage = "An error occured."
        self.flashErrorMessage errorMessage
      )
    ).then((response) -> (
      self.survey_recipients = response.recipients
      options = ''
      collaborator_list = ''
      self.survey_collaborators = response.collaborators.map (collaborator) ->
        collaborator.email
      if response.status == "published" || "draft"
        self.survey_recipients.forEach((recipient) -> (
          options += """
            <li>
              #{recipient.name} #{recipient.cycle}
              <span data-target="#{recipient.cycle_center_id}" class="close">&times;</span>
            </li>
          """
        ))
        self.survey_collaborators.map (recipient) ->
          collaborator_list += """
            <li>
              #{recipient}
              <span data-target="#{recipient}" class="close">&times;</span>
            </li>
          """

        $('#main-share-modal .selected-collaborators').html(collaborator_list )
        $('#main-share-modal .selected-cycles').html(options)
        $('#main-share-modal .selected-cycles .close').on 'click', -> (
          remove_id = $(this).data('target')
          self.survey_recipients =
            self.survey_recipients.filter((recipient) -> recipient.cycle_center_id != remove_id)
          $(this).parent().remove()
          self.populateRecipients()
        )
        $('#main-share-modal .selected-collaborators .close').on 'click', -> (
          self.removeCollaborator($(this))
        )

        self.getSurveyRecipients()
        if response.edit_response
          $("#edit_responses").addClass('is-checked')
        $("#survey_share_start_date").val(moment.utc(response.start_date).format('DD MMM YYYY HH:mm'))
        $("#survey_share_end_date").val(moment.utc(response.end_date).format('DD MMM YYYY HH:mm'))
      if response.status == "published" || "archived"
        $("#survey-update-btn").removeClass("hidden")
      $("#survey-2-title").val(response.title)
     
      if response.status == "published"
         $("#survey-save-progress").addClass("hidden")
      if response.description != ''
        $("#add-survey-description-btn").click()
        $(".survey-description").val(response.description)
      questions = []
      response.survey_sections.forEach((section, section_index) ->
        self.addSection()
        if section.survey_section_rules.length
          optionId = section.survey_section_rules[0].survey_option_id
          self.configureLinkedSection $("#section-#{self.sectionsId - 1}"), optionId
        section.survey_questions.forEach((question, section_id) -> (
          self.addQuestion(section_index)
          lastQuestionId = self.questionsCount - 1
          for key, value of self.questions[lastQuestionId]
            question[key] = value unless key of question    
          questions.push question
          self.configureQuestion(question, lastQuestionId)
          )
        )
      )
      self.questions = questions.map((question, index) ->
        question.selected_type = self.questions[index].selected_type
        question
      )
      self.updatePreview()
    ))

  configureLinkedSection : (section, option_id) ->
    setTimeout( () ->
      (
        option = $(".answer[option-id=#{option_id}]")
        optionPosition = option.index(".answer") + 1
        questionPosition = option.parents(".cloned, .cloned-linked").index(".cloned, .cloned-linked") + 1
        sectionPosition = option.parents(".cloned-section").index(".cloned-section") + 1
        section.find(".more-icon").hover()
        section.find("#link-question").click()
        $("#section-link-dropdown").val(sectionPosition).selectmenu("refresh").trigger("selectmenuchange")
        $("#question-link-dropdown").val(questionPosition).selectmenu("refresh").trigger("selectmenuchange")
        $("#option-link-dropdown").val(optionPosition).selectmenu("refresh").trigger("selectmenuchange")
        $("#link-confirm-btn").click()
        $('.toast').hide()
      )
    ,0)

  configureQuestion: (question, id) ->
    self = @
    $("#question-#{id} .select-question").click()
    $("#question-#{id} .question-body").val(question.question)
    if question.is_required == true
      $(".mdl-switch").click()
      if($("#question-#{id} .mdl-switch")).hasClass('is-checked')
        @show ["#question-#{id} .required"]
        @hide ["#question-#{id} .not-required"]
    switch @unMapType(question.type)
      when "multiple-choices"
        $("#question-#{id} .multiple-choice-icon").click()
        question.survey_options.map (option, index) ->
          $("#question-#{id} .add-choice").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .add-choice").trigger(e);
          setTimeout(
            () -> (
              $("#question-#{id} #answer-#{index}").attr("option-id", option.id))
          , 0)

          self.updatePreview()
        self.configureQuestionDescriptions(question, id)
      when "checkboxes"
        $("#question-#{id} .checkboxes-icon").click()
        question.survey_options.map (option, index) ->
          $("#question-#{id} .add-choice").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .add-choice").trigger(e);
          self.updatePreview()
        self.configureQuestionDescriptions(question, id)
      when "dropdown"
        $("#question-#{id} .dropdown-icon").click()
        question.survey_options.map (option, index) ->
          $("#question-#{id} .add-choice").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .add-choice").trigger(e);
          setTimeout(
            () -> (
              $("#question-#{id} #answer-#{index}").attr("option-id", option.id))
          , 0)
        self.configureQuestionDescriptions(question, id)
      when "scale"
        $("#question-#{id} .scale-icon").click()
        $("#question-#{id} .slider-message").html(question.scale.max)
        $("#question-#{id}  #slider-input").val(question.scale.max)
        min = question.scale.min
        max = question.scale.max
        fraction = (max - min) / (10 - min)
        $("#question-#{id} .mdl-slider__background-lower").css("flex", "#{fraction} 1 0%")
        $("#question-#{id} .mdl-slider__background-upper").css("flex", "#{1-fraction} 1 0%")
        self.addScaleValuesToState(question.scale, "#question-#{id}")
        self.configureQuestionDescriptions(question, id)
      when "multi-choice-grid"
        $("#question-#{id} .multi-choice-grid-icon").click()
        question.survey_options.rows.map (option) ->
          $("#question-#{id} .row-addon").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .row-addon").trigger(e);
        question.survey_options.columns.map (option) ->
          $("#question-#{id} .column-addon").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .column-addon").trigger(e);
        self.configureQuestionDescriptions(question, id)
      when "checkbox-grid"
        $("#question-#{id} .checkbox-grid-icon").click()
        question.survey_options.rows.map (option) ->
          $("#question-#{id} .row-addon").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .row-addon").trigger(e);
        question.survey_options.columns.map (option) ->
          $("#question-#{id} .column-addon").val(option.option)
          e = $.Event("keyup");
          e.which = 13
          $("#question-#{id} .column-addon").trigger(e);
        self.configureQuestionDescriptions(question, id)
      when "date"
        $("#question-#{id} .datepicker-icon").click()
        $("#question-#{id} .min-date").val(question.date_limits.min)
        $("#question-#{id} .max-date").val(question.date_limits.max)
        self.configureQuestionDescriptions(question, id)
      when "paragraph"
        $("#question-#{id} .paragraph-icon").click()
        self.configureQuestionDescriptions(question, id)
      when "time"
        $("#question-#{id} .clock-icon").click()
        self.configureQuestionDescriptions(question, id)

      when "picture-options"
        $("#question-#{id} .picture-icon")[0].click()
        question.survey_options.map (option, index) ->
          option.index = index
          $(".photo-uploads").show()
          if option.survey_option_question_id
            image = self.processMediaLink option.option
            imageContent = """
            <div class="survey-item-container">
              <div class="answer photo-uploads" id="answer-#{option.index}">
                <div key="#{option.index}" id="close-#{option.index}" class="close"></div>
                  <div class="photo-size">
                    <span class="file-name">#{image.base_name}.#{image.extension}</span>
                  </div>
              </div>
            </div>
          """
          else
            image = option.option
            imageContent = """
            <div class="survey-item-container">
              <div class="answer photo-uploads" id="answer-#{option.index}">
                <div key="#{option.index}" id="close-#{option.index}" class="close"></div>
                  <div class="photo-size">
                    <span class="file-name">#{image}</span>
                  </div>
              </div>
            </div>
          """
          imageContent
          $("#question-#{id}").find(".option-picture-answers").append(imageContent)
          $("#question-#{id} #close-#{option.index}").on 'click', (event) ->
            self.deletePictureOption(question.survey_options, option.index)

          setTimeout(
            () -> (
              $("#question-#{id} #answer-#{index}").attr("option-id", option.id))
          , 0)

        @addMediaOptionsToState(question.survey_options, "#question-#{id}")
        self.configureQuestionDescriptions(question, id)

      when "picture-checkbox"
        $("#question-#{id} .picture-icon")[1].click()
        question.survey_options.map (option, index) ->
          option.id = index
          if option.survey_option_question_id
            image = self.processMediaLink option.option
            imageContent = """
            <div class="survey-item-container">
              <div class="answer photo-uploads" id="answer-#{option.id}">
                <div key="#{option.id}" id="close-#{option.id}" class="close"></div>
                  <div class="photo-size">
                    <span class="file-name">#{image.base_name}.#{image.extension}</span>
                  </div>
              </div>
            </div>
          """
          else
            image = option.option
            imageContent = """
            <div class="survey-item-container">
              <div class="answer photo-uploads" id="answer-#{option.id}">
                <div key="#{option.id}" id="close-#{option.id}" class="close"></div>
                  <div class="photo-size">
                    <span class="file-name">#{image}</span>
                  </div>
              </div>
            </div>
          """
          imageContent
          $("#question-#{id}").find(".checkbox-picture-answers").append(imageContent)
          $("#question-#{id} #close-#{option.id}").on 'click', (event) ->
            self.deletePictureOption(question.survey_options, option.id)

        @addMediaOptionsToState(question.survey_options, "#question-#{id}")
        self.configureQuestionDescriptions(question, id)

  deletePictureOption: (questionOptions, index) ->
    event.target.closest(".answer.photo-uploads").remove()
    delete questionOptions[index]
    @updatePreview()

  addMediaOptionsToState: (options, name_space) ->
    @questions.map (question) ->
      if question.name_space == name_space
        question.survey_options = options

  addScaleValuesToState: (values, name_space) ->
    @questions.map (question) ->
      if question.name_space == name_space
        question.scale = values

  processMediaLink: (string) ->
    extractor_regex = /^(?:.*)\/(\w*).(\w+)$/gi
    processed_link = extractor_regex.exec(string)
    { base_name: processed_link[1], extension: processed_link[2] }

  toggleButtons: ->
    if pageUrl[2] == 'setup'
      $('#survey-update-btn').css('display', 'none')
      $('#send-btn-shelter').css('display','block')
      $('#update-btn-shelter').css('display','none')
      $('#survey-share-btn').css('display','block')
    if pageUrl[3] == 'edit'
      $('#survey-update-btn').css('display', 'block')
      $('#send-btn-shelter').css('display','none')
      $('#update-btn-shelter').css('display','block')
      $('#survey-share-btn').css('display','block')

  onUpdateSurvey: ->
    self = @
    @toggleButtons()
    $('#submit-btn-shelter').on 'click', =>
      survey = self.getSurvey("published")
      collaborators = self.survey_collaborators
      return unless survey
      $('.update-btn-shelter').addClass('disabled')
      self.api.updateSurvey(
        survey,
        (response) -> (
          error = if response.responseJSON then response.responseJSON.error else {}
          errorMessage =
            if error.survey
              error.survey.message
            else if error.survey_question
              "Question #{error.survey_question.position}: #{error.survey_question.message}"
            else
              "An error occured."
          self.flashErrorMessage errorMessage
          self.surveyShareModal.close()
          $('.update-btn-shelter').removeClass('disabled')
        )
      ).then(
        (response) -> (
          self.flashSuccessMessage response.message
          setTimeout (=>
            window.location.href = '/surveys-v2'
          ), 500
        )
      )

  configureQuestionDescriptions: (question, id) ->
    self = @
    question_description = question.description
    if question_description != ''
      $("#question-#{id} .add-description-question").click()
      if question.description_type == 'text'
        $("#question-#{id} .text-description-option").click()
        $("#question-#{id} .text-description").val(question.description)
        e = $.Event("keyup")
        e.which = 13
        $("#question-#{id} .text-description").trigger(e)
      else 
        if typeof question_description == 'string'
          $("#{question.name_space} .#{question.description_type}-description-option").click()
          setTimeout ( -> self.setMediaDescription(question, id)), 0
    
  getCollaborators: ->
    self = @
    collaborator_list = ''
    self.collaborators.forEach((option) ->
      already_selected = self.survey_collaborators.find((recipient) ->
        recipient == option
      )
      return if already_selected
      collaborator_list += """
        <div class='collaborators-option'>
          <p>#{option}</p>
          <input type='hidden' value='#{option}'/>
        </div>"""
    )
    $('.collaborator-options-list').html(collaborator_list )
    $('#main-share-modal .collaborators-option').on 'click', -> (
      self.selectCollaborator($(this))
    )
  
  selectCollaborator: (target) ->
    self = @
    selected_email = target.find('input').val()
    selected_recipient = self.collaborators.find((recipient) ->
      recipient == selected_email
    )
    self.survey_collaborators.unshift(selected_recipient)
    collaborator_list = ''
    self.survey_collaborators.forEach((recipient) -> (
      collaborator_list += """
        <li>
          #{recipient}
          <span data-target="#{recipient}" class="close">&times;</span>
        </li>
      """
    ))
    $('#main-share-modal .selected-collaborators').html(collaborator_list )
    $('#main-share-modal .selected-collaborators .close').on 'click', -> (
      self.removeCollaborator($(this))
    )
    self.getCollaborators()

  removeCollaborator: (target) ->
    self = @
    remove_email = target.data('target')
    self.survey_collaborators =
      self.survey_collaborators.filter((recipient) -> recipient != remove_email)
    target.parent().remove()
    self.getCollaborators()

  setDateLimits: (event, limit, target) ->
    @questions.map((question) ->
      if question.name_space == target
        question.date_limits[limit] = $(event.target).val()
    )
