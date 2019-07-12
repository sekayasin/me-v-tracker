class SurveyV2.Editor.UI
  constructor: (@cloneSurvey, preview, initDeleteModal) ->
    @openSurveyPreviewModal = preview
    @initializeSurveyDeleteModal = initDeleteModal
    @surveyPreviewModal = new Modal.App('#survey-v2-preview-modal', 672, 672, 598, 598)
    @helpers = new Helpers.UI()

  setInitial: (surveyInitial) =>
    @surveyInitial = surveyInitial


  initializeSurveyDuplication: ->
    self = @
    $('.new_survey_duplicate_btn').each((index, elem) ->
      $(elem).off('click').on 'click', =>
        survey_id = $(this).data('survey_id')
        return self.flashErrorMessage 'This is an old survey' unless Number.isInteger(survey_id)
        self.cloneSurvey(survey_id, (response) -> (
          message = 'There was an error cloning the survey'
          self.flashErrorMessage message
        ))
        .then((response) -> (
          self.flashSuccessMessage response.message
          self.createDuplicateSurvey response.survey
          self.initializeSurveyDuplication()
          self.initializeSurveyDeleteModal()
          self.openSurveyPreviewModal()
          self.surveyInitial.initializeGetSurvey()
        ))
    )

  createDuplicateSurvey: (survey) ->
    cardElement = $("<div></div>")
    surveyResponses = """<li class="drop-item"><a href="/surveys-v2/responses">View Responses</a></li>"""
    shareReport = """<li class="drop-item"><a href="#">Share Report</a></li>"""
    if survey.status == "draft"
      surveyResponses = ""
      shareReport = ""
    DOMElement = """
      <div class='survey-card glow' data-survey_id="#{survey.id}">
        <div class="body survey-card-body">
          <div class="title">#{@helpers.capitalizeSurvey(@helpers.truncateTitle(survey.title))}</div>
          <div class="survey-status">#{@helpers.capitalizeSurvey(survey.status)}</div>
        </div>
        <div class="foot">
          <div class="resp">10 Responses</div>
          <div class="more-icon">
            <ul class="drop-option">
              <li class="drop-item"><a href="/surveys-v2/responses">View Response</a></li>
              <li class="drop-item" id="edit-form"><a href="/surveys-v2/#{survey.id}/edit">Edit Form</a></li>
              <li class="drop-item new_survey_duplicate_btn" data-survey_id="#{survey.id}">
                <a href="#" data-survey_id="#{survey.id}">
                  Duplicate
                </a>
              </li>
              #{shareReport}
              <li class="drop-item"><a data-survey_id="#{survey.id}" class="delete">Delete</a></li>
            </ul>
          </div>
        </div>
      </div>
    """
    cardElement.html DOMElement
    $('#new-survey-btn').after DOMElement
    $('.glow')
    .animate({backgroundColor: '#AADDBB'}, 1000)
    .animate({backgroundColor: 'none'}, 1800)
    .removeClass('glow')

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)
