class HolisticEvaluations.App
  constructor: ->
    @api = new HolisticEvaluations.API()
    @ui = new HolisticEvaluations.UI()

  start: =>
    @ui.handleOpenHolisticModal(@api.getHolisticAverages, @api.getEvaluationEligibility)
    @ui.checkAdminLfaAccess()
    @ui.submitHolisticEvaluationDetails(@validateFields)
    @saveFinalEvaluation()

  saveFinalEvaluation: ->
   @ui.clickSubmitBtn(@api.saveHolisticEvaluation)

  validateFields: (evaluationData, checkSpaces) ->
    blank = ''
    if not evaluationData.score
      blank = 'no score'
    else if evaluationData.score in ["-2", "-1", "2"] && (
      not evaluationData.comment || checkSpaces)
      blank = 'no comment'
    return blank
