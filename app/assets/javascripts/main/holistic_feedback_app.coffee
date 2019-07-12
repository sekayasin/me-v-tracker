class HolisticFeedback.App
  constructor: ->
    @holisticFeedbackUI = new HolisticFeedback.UI()
    @holisticFeedbackApi = new HolisticFeedback.API()

  start: =>
    @holisticFeedbackUI.initializeHolisticFeedback(
      @holisticFeedbackApi.saveHolisticFeedback
    )
