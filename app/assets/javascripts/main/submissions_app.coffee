class Submissions.App
  constructor: ->
    @api = new Submissions.API()
    @ui = new Submissions.UI(
      @api.fetchPhases,
      @api.fetchFeedbackDetails,
      @api.getFeedbackMetadata,
      @api.fetchOutput,
      @api.fetchReflectionDetails,
      @api.fetchLearners
    )
    @filterUI = new Filter.UI(
      @api.fetchFilterParams,
      @api.fetchCycles,
      @api.fetchFacilitators,
      @api.fetchLearners
    )
    
  start: ->
    @ui.initializeTabs('overview-bar')
    @ui.initializeAccordions()
    @ui.submitOrSaveFeedback(@saveFeedback)
    @filterUI.populateLearners()
    @filterUI.initializeFilter()
    @filterUI.displayFilterPane()
    @filterUI.filterDropdowns()

  saveFeedback: (feedbackDetails) =>
    finalized = feedbackDetails.finalized
    @ui.loaderUI.show()
    @api.giveFeedback(feedbackDetails).then((data) =>
        if finalized
          @ui.revealToast("Feedback successfully submitted", "success")
          Notifications.App.sendLearnerFeedbackNotification(data)
        else
          @ui.revealToast("Feedback successfully saved", "success")
        @ui.modal.close()
        @ui.loaderUI.hide()
      )
