class Survey.App
  constructor: ->
    @api = new Survey.API()
    @programFeedbackApi = new ProgramFeedback.API
    @survey = new Survey.UI(
      @api.getSurveys,
      @api.getAllCycles,
      @api.createSurvey,
      @api.updateSurvey,
      @api.getSurveysRecipients,
      @api.closeSurvey,
      @programFeedbackApi.saveFeedback,
      @programFeedbackApi.getFeedbackScheduleDetails,
      @programFeedbackApi.saveScheduleFeedback,
      @api.deleteSurvey
    )

  start: ->
    @survey.initializeSurveyModal()
    @survey.initializeFeedbackModal()
    @survey.initializeSurveyTable()
    @survey.openFeedbackModalOnLoad()

  onReceiveSurvey: (survey) =>
    @survey.onReceiveSurvey(survey)

  openFeedBackPopUp: (question) =>
    @survey.openFeedbackPopupModal(question)
