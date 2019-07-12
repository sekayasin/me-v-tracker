class DecisionHistory.App
  constructor: ->
    @ui = new DecisionHistory.UI()
    @api = new DecisionHistory.Api()

  start: =>
    @ui.view(@getHistory)

  getHistory: =>
    self = @
    learnerId = location.pathname.split('/')[3]
    self.api.getDecisionHistory(learnerId).then (data) ->
      self.ui.populateDecisionHistoryModal data
