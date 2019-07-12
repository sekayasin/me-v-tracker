class PersonalFeedback.App
  constructor: ->
    @api = new PersonalFeedback.API()
    @ui = new PersonalFeedback.UI()
    @loaderUI = new Loader.UI()
    @setAssessments = {}

  start: =>
    self = @
    self.ui.openPersonalFeedbackModal().then (response) ->
      # Get feedback details promise 
      self.api.getFeedbackMetadata().then (feedbackDetails) ->
        data = feedbackDetails
        self.ui.populateDropdown('#learner-phase', data.phases)
        self.ui.populateDropdown('#learner-impression', data.impressions, self.ui.impressionText)
        self.setAssessments = self.populateAssessments().then (response) =>
          self.ui.frameworkCriteriaChangeEvents(response)

    self.ui.selectPhaseChanged( ->
      self.populateAssessments()
    )

    self.ui.selectOutputImpressionChanged( ->
      self.getLearnerFeedback()
    )

    self.ui.submitPersonalFeedback(@validateFields)

  getLearnerFeedback: =>
    self = @
    # Get feedback details promise 
    self.api.getLearnerFeedback(self.ui.getPersonalFeedback()).then (learnerFeedbackDetails) ->
      self.ui.getPersonalFeedbackDetails(learnerFeedbackDetails)

  populateAssessments: =>
    self = @
    # Get assessment metadata details promise 
    self.api.getAssessmentMetadata().then (assessmentMetadata) ->
      self.ui.populateFrameworkDropdown('#learner-framework', assessmentMetadata)
      self.ui.populateCriteriaDropdown('#learner-framework', assessmentMetadata)
      self.ui.populateOutputDropdown()
      assessmentMetadata
  
  validateFields: (personalFeedback) =>
    self = @
    if personalFeedback.assessment_id isnt null and personalFeedback.impression_id > 0
      self.saveFeedback(personalFeedback)
      self.ui.resetModal()
    else
      self.ui.validateOutputImpression(personalFeedback)

  saveFeedback: (personalFeedback) =>
    self = @
    self.loaderUI.show()
    @api.createUpdatePersonalFeedback(personalFeedback).then () ->
      self.scrollToTop()
      self.loaderUI.hide()
      self.ui.revealToast("Feedback successfully saved", "success")
      self.ui.modal.close()
  
  scrollToTop: () =>
    window.scrollTo(100, 0)
