class HolisticPerformanceHistory.App
  constructor: ->
    @ui = new HolisticPerformanceHistory.UI()
    @api = new HolisticPerformanceHistory.Api()

  start: =>
    @ui.viewHistory(@getHistoryDetails)
    @ui.clickEditHolisticScores()
    @ui.clickSaveHolisticEvaluationButton(@api.updateHolisticEvaluation)
    @ui.clickCancelEditMode()

  getHistoryDetails: (learnerId)=>
    self = @
    self.api.getScoresHistory(learnerId).then (data) ->
      self.ui.populateScoresHistoryModal(data, self.api.updateHolisticEvaluation)
      self.ui.downloadHolisticEvaluationCSV(data)