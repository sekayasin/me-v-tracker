class SelectDlc.App
  constructor: ->
    @ui = new SelectDlc.UI

  redirectLearner: (programId) =>
    localStorage.setItem('programId', programId)
    window.location = "/analytics"

  start: =>
    self = @
    @ui.getLearnerData('.proceed-btn', '#program-select', 'dt a span.value', self.redirectLearner)
