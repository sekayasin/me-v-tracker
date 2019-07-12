class LearnerScore.App
  constructor: ->
    @api = new LearnerScore.API()
    @learnerDashboardApi = new LearnersDashboard.API()
    @ui = new LearnerScore.UI()
    @learnerDashboardUi =  new LearnersDashboard.UI()
    @backendValidation = new BackendValidation.App()
    @decisionHistoryApi = new DecisionHistory.Api()

  start: =>
    @ui.loadVerifiedOutputs(@api.getVerifiedOutputs)
    @ui.handlePhaseDropdown(@api.getAssessments, @api.getSubmittedScores)
    @ui.handleFrameworkDropdown(@api.getSubmittedScores)
    @ui.handleCriteriumDropdown(@api.getSubmittedScores)
    @ui.initializeDecisionModal(@learnerDashboardApi.getDecisionReason, @decisionHistoryApi.getDecisionHistory)
    @ui.submitScore(
      @api.sendScoreData,
      @checkBlankFields,
      @backendValidation,
      @api.getVerifiedOutputs
    )
    @ui.handleOnPageLoad(@api.getAssessments, @api.getSubmittedScores, @api.getOutputMetrics)
    @ui.handleOnClickSaveDecision(@saveLearnersDecisionDetails)


  isBlankField: (field) =>
    return field == null or field.trim().length == 0

  checkBlankFields: (scoreData) =>
    if scoreData.length == 0
      return 'Score(s) and Comment(s)'

    for score in scoreData
      if @.isBlankField(score['score'])
        return 'Score(s)'
      else if @.isBlankField(score['comments']) && score['score'] in ["3", "1"]
        return 'Comment(s)'

    return ""


  fillInputFields: (learnerDecisionStatus, decisionData) ->
    unless decisionData.decisions['stage'] == true
      learnerDecisionStatus = $('#decision-selects').val()
      $('.decision-one').val(learnerDecisionStatus)
      $('.decision-one').selectmenu("refresh")
      return
    learnerDecisionStatus = $('#decision-selects').val()
    $('.decision-two').val(learnerDecisionStatus)
    $('.decision-two').selectmenu("refresh")

  saveLearnersDecisionDetails: (
      learnerDecisionStatus,
      status,
      learnerProgramId,
      decisionData,
      decisionStatusElementVal
    ) =>
      self = @
      @learnerDashboardApi.setDecisionStatus(status, learnerProgramId)
      return @learnerDashboardApi.saveDecision(decisionData).
        then (saveResponse) =>
          @learnerDashboardUi.closeDecisionUpdateModal()
          @learnerDashboardUi.saveDecisionToast(saveResponse)
          return unless decisionData.decisions['stage'] == 1
          if learnerDecisionStatus == "Advanced"
            $(".decision-dropdown.second-decision").find("#not-applicable").remove()
            $(".decision-dropdown.second-decision").find("#advanced").remove()
            $(".decision-dropdown.second-decision").attr("disabled", false)
            $(".decision-dropdown.second-decision").selectmenu("refresh")
          else
            $(".decision-dropdown.second-decision").attr("disabled", true)
            $(".decision-dropdown.second-decision").selectmenu("refresh")
