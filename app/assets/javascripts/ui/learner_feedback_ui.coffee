class LearnerFeedback.UI
  constructor: -> 
    @modal = new Modal.App('#learner-feedback-modal', 575, 575, 320, 320)

  openLearnerFeedbackModal: =>
    self = @
    $('.learner-feedback-btn').click ->
      $('#holistic-performance-evaluation').css("display", "none")
      $('#holistic-performance-history').css("display", "none")
      $('#edit-learner-bio-info-modal').hide()
      self.modal.open()
      self.pageScroll("hidden")

    $(document). on 'click', '.close-learner-feedback', () ->
      self.modal.close()
      self.pageScroll("auto")
      $('#holistic-performance-evaluation').css("display", "none")
    
  pageScroll: (style) =>
    $('body').css('overflow', style)
