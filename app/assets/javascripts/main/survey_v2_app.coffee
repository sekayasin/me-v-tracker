class SurveyV2.App
  constructor: ->
    @api = new SurveyV2.API()
    @ui = new SurveyV2.UI(@api)
    @surveyPreview =  new SurveyV2.Preview.UI(@api, @ui)
    @surveyEditUI = new SurveyV2.Editor.UI(
      @api.cloneSurvey,
      @surveyPreview.openSurveyPreviewModal,
      @ui.initializeSurveyDeleteModal,
      @ui.initializeSurveyEditModal)
    @surveyRespond = new SurveyV2.Respond.UI(
      @api.getSurveysV2,
      @api.getSurvey,
      @api.submitResponse,
      @api.getSurveyRespondent,
      @api.getSurveyResponseData
    )
    @surveyInitial = new SurveyV2.Initial.UI(@api.getSurveysV2, @surveyEditUI, @surveyPreview.openSurveyPreviewModal, @ui.initializeSurveyDeleteModal, @ui.initializeSurveyEditModal)
    @surveyEditUI.setInitial(
      @surveyInitial
    )
    @statsUI = new SurveyV2.Stats.UI(
      @api.getASurvey,
      @api.getSurveyResponses,
      @api.shareSurvey,
      @api.getAllAdmin
    )

  start: ->
    @ui.initializeCreateForm()
    @ui.initializeShareModal()
    @ui.initializeDatePicker()
    @ui.initializePreviewModal()
    if pageUrl[3] == "edit"
      @ui.initializeEditForm()
    @statsUI.initializeResponseModal()
    if pageUrl[2] == "responses"
      @statsUI.setup()
    @surveyRespond.initializeRespond()
    if pageUrl[2] == "respond"
      @surveyRespond.initializeEditResponse()
    @surveyEditUI.initializeSurveyDuplication()
    @surveyPreview.initalizePreview()
    @ui.initializeSurveyDeleteModal()
    @surveyInitial.initializeGetSurvey()
    @ui.initializeSurveyFullScreen()
    @ui.initializeSurveyEditModal()
