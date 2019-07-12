class SurveyV2.Preview.UI
  constructor: (@api, @surveyV2Parent) ->
    @questions = []
    @surveyPreviewModal = new Modal.App('#survey-v2-preview-modal', 672, 672, 598, 598)
    @helpers = new Helpers.UI()

  initalizePreview: ->
    @openSurveyPreviewModal()

  openSurveyPreviewModal: =>
    self = @
    $('.survey-card-body').each((index, elem) ->
      $(elem).off('click').on 'click', =>
        $(".preview-body").html(" ")
        survey_id = $(this).closest(".survey-card").data('survey_id')
        self.api.getASurvey(survey_id, (error) -> (
          errorMessage = "There was an error getting your survey"
          self.flashErrorMessage errorMessage
        ))
          .then((response) ->
            self.buildPreviewModal(response)
            self.populateEditButton(response.id)
            self.populateResponsesButton(response.id)
            self.hideDraftToggle(response.status)
            self.setToggleState(response.status)
            self.onToggleChange(response.status, response.id)
            self.surveyPreviewModal.open()
            self.image_preview_callback()
        )
        $('#preview-close').on 'click', =>
            setTimeout (
              self.surveyPreviewModal.close()
            ), 500

    )

  populateEditButton: (surveyId) =>
    $("#edit_form").attr("href", "/surveys-v2/#{surveyId}/edit")

  populateResponsesButton: (surveyId) =>
    $("#view_responses").attr("href", "/surveys-v2/responses/#{surveyId}")

  setToggleState: (status) ->
    if status == "archived"
      $("#archive-toggle").removeClass("is-checked")
    else
      $("#archive-toggle").addClass("is-checked")

  onToggleChange:(status, surveyId) =>
    self = @
    $(".mdl-switch__input").off('click').on 'click', ->
      $(".mdl-switch").toggleClass('is-checked')
      if($(".mdl-switch")).hasClass('is-checked')
        if status == "archived"
          self.saveNewStatus("published", surveyId)
          status="published"
      else
        if status == "published"
          self.saveNewStatus("archived", surveyId)
          status="archived"
      setTimeout (=>
        self.setToggleState(status)
        $('.toast').hide()
      ), 0

  saveNewStatus: (status, survey_id) ->
    self = @
    survey_state = {
      status: status
      survey_id: survey_id
    }
    newStatus = self.helpers.capitalizeSurvey(status)
    if newStatus == "Archived"
      newStatus = "On Hold"
    self.api.toggleArchiveSurvey(
        survey_state,
        (response) -> (
          error = if response.responseJSON then response.responseJSON.error else {}
          errorMessage = if error.message then error.message else "An error occured."
          self.flashErrorMessage errorMessage
        )
      ).then(
        (response) -> (
          self.flashSuccessMessage response.message
          $(".survey-card##{survey_id} .survey-status").text(newStatus)
        )
      )

  hideDraftToggle: (status) ->
    if status == "draft"
      $(".title-right").addClass("hidden")
    else
      $(".title-right").removeClass("hidden")

  buildPreviewModal: (response) =>
    @setModaltitle(response.title, response.survey_responses_count)
    @buildSection(response)

  appendNamespaceSection: (section, sectionId) ->
    self = @
    count = 0
    questions = []

    mappedSection = section.survey_questions.map (question, i) ->
      question.name_space = "question-#{count}"
      question.selected_type = self.surveyV2Parent.unMapType(question.type)
      question.section = sectionId + 1
      ++count
      question
    questions = questions.concat mappedSection
    questions

  setModaltitle: (title, responseCount) ->
    $(".modal-title > .title").html(title)
    $(".modal-title .response-count")
      .html("#{responseCount} #{if responseCount == 1 then 'Response' else 'Responses'}")
    if responseCount == 0
      $("#view_responses").hide()
    else
      $("#view_responses").show()

  buildSection: (response) =>
    self = @
    @currentSection = 1
    @surveyV2Parent.currentPreviewSection =  1
    response.survey_sections.forEach((section, index) ->
      mappedQuestion = self.appendNamespaceSection(section, index)
      self.surveyV2Parent.questions =  mappedQuestion
      DOMQuestion = self.surveyV2Parent.getBuilderPreview()

      clonedSection = self.cloneSection(index)
      if index == 0 then clonedSection.removeClass("ui-helper-hidden").remove("#clone-section").addClass("preview-active")
      $(".preview-body").append(clonedSection)
      self.displaySectionNextButton(response.survey_sections, index)
      self.displaySectionPrevButton(index)

      ++self.surveyV2Parent.currentPreviewSection
      $("#section-#{index + 1} > .question-body-content").append(DOMQuestion)
    )
    @handleNextClick()
    @handlePrevClick()
    $('.survey-dropdown').selectmenu()

  cloneSection: (sectionId) =>
    id = sectionId + 1
    cloned_section = $("#clone-section")
                        .clone()
                        .attr("id", "section-#{id}")
                        .attr("data-section", id)
    cloned_section

  displaySectionNextButton: (section, index) =>
    return unless section.length != index + 1 || section.length < index + 1
    $("#section-#{index + 1}").find(".preview-next").removeClass("ui-helper-hidden")

  displaySectionPrevButton: (index) =>
    return if index + 1 == 1
    $("#section-#{index + 1}").find(".preview-prev").removeClass("ui-helper-hidden")

  handleNextClick: () ->
    $(".preview-next").on "click", =>
      @currentSection++
      activeSection = $(".preview-body").find(".preview-active").data("section")
      $(".preview-body").find(".preview-active").removeClass("preview-active").addClass("ui-helper-hidden")
      $(".preview-body").find("#section-#{activeSection + 1}").removeClass("ui-helper-hidden").addClass("preview-active")

  handlePrevClick: () ->
    $(".preview-prev").on "click", =>
      @currentSection--
      activeSection = $(".preview-body").find(".preview-active").data("section")
      $(".preview-body").find(".preview-active").removeClass("preview-active").addClass("ui-helper-hidden")
      $(".preview-body").find("#section-#{activeSection - 1}").removeClass("ui-helper-hidden").addClass("preview-active")

  image_preview_callback: () -> 
    self = @
    $(".enlarge-image").click () ->
      param = $(this).siblings('img').attr('src')
      self.showImagePreviewModal param
  

  showImagePreviewModal: (image) ->
    $('.preview-modal, .close-backdrop').css('display', 'block')
    $('#preview-content').attr('src', image)
    $('.close-modal, .close-backdrop').click () =>
      $('.preview-modal').css('display', 'none')

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)
