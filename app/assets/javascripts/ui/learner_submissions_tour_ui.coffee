class LearnerSubmissionsTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @valueOutputTour = introJs()
    @outputQualityTour = introJs()
    @feedbackModalTour = introJs()
    @submissionModalTour = introJs()
    @takeTourAgainHint = introJs()
    @role = ""
    @tourContent = {}
    @clickedHints = { 0: false, 1: false }
    @hintsOnPage = 0

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 99)
    $(".introjs-helperLayer").css("z-index", 99)

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  initSubmissionModalTour: ->
    self = @
    $(".action-column .lfa-feedback-modal").click()
    @submissionModalTour.setOptions({
      steps: @tourContent.submissionModalSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
    })
    @submissionModalTour.start()
    @submissionModalTour.oncomplete ->
      $(".close-button").click()
      this.showHints()
      this.hideHint(2)
      $("#accordion-title-1").click()
    @submissionModalTour.onafterchange ->
      setTimeout(self.reduceHelperLayer, 10)

  initFeedbackModalTour: ->
    self = @
    @mainIntro.hideHints()
    $(".lfa-feedback-modal").click()
    @feedbackModalTour.setOptions({
      steps: @tourContent.feedbackModalSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
    })
    @feedbackModalTour.start()
    @feedbackModalTour.onafterchange ->
      setTimeout(self.reduceHelperLayer, 10)
    @feedbackModalTour.oncomplete  ->
      $(".close-button").click()
      $("#accordion-title-2").click()

    @feedbackModalTour.onbeforeexit ->
      self.showHints()
    
    @feedbackModalTour.onexit ->
      self.hintsOnPage -= 1
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );


  initValueOutputTour: ->
    self = @
    @clickedHints[0] = true
    atEnd = false
    @mainIntro.hideHints()
    @valueOutputTour.setOptions({
      steps: @tourContent.valueOutputSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      scrollToElement: true,
      scrollPadding: -1000000,
      doneLabel: "Click"
    })
    @valueOutputTour.start()
    $("#accordion-title-2").click()

    @valueOutputTour.onbeforeexit ->
      $("#accordion-title-2").click() unless atEnd
      self.showHints()

    @valueOutputTour.onchange ->
      if this._currentStep == 8
        atEnd = true

    @valueOutputTour.onexit ->
      if atEnd
        self.initFeedbackModalTour()
        setTimeout(self.reduceIntroZIndex, 10)

  initOutputQualityTour: ->
    self = @
    @clickedHints[1] = true
    @mainIntro.hideHints()
    @outputQualityTour.setOptions({
      steps: @tourContent.outputQualitySteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      scrollToElement: true,
      scrollPadding: -1000000
      doneLabel: "Click"
    })
    @outputQualityTour.start()
    $("#accordion-title-1").click()

    @outputQualityTour.onexit  ->
      self.hintsOnPage -= 1
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );
      if $(".action-column .lfa-feedback-modal").length
        self.initSubmissionModalTour()
        setTimeout(self.reduceIntroZIndex, 10)
      else
        $("#accordion-title-1").click()

    @outputQualityTour.onbeforeexit ->
      self.showHints()

  showHints: ->
    for hintId, hasClicked of @clickedHints
      @mainIntro.showHint(hintId) unless hasClicked

  initLearnerSubmissionsTour: ->
    self = @
    $("#tour-icon").off("click").click ->
      self.startLearnerSubmissionsTour()
    @tourAPI.getUserTourStatus("#{pageUrl[1]}-card").then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startLearnerSubmissionsTour()

  startLearnerSubmissionsTour: ->
    self = @
    @clickedHints = { 0: false, 1: false }
    @mainIntro.removeHints()
    @mainIntro.setOptions({
      steps: @tourContent.learnerSubmissionSteps,
      hints: @tourContent.learnerSubmissionsHints,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
      hintButtonLabel: "Click"
      hidePrev: true
      hideNext: true
    })

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.onafterchange ->
      if this._currentStep == 8
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      this.addHints()
      self.showHints()
      self.hintsOnPage = self.tourContent.learnerSubmissionsHints.length
      self.tourAPI.createTourEntry("#{pageUrl[1]}-card")

    @mainIntro.onexit ->
     self.tourAPI.createTourEntry("#{pageUrl[1]}-card")
     
    @mainIntro.hideHints()
    @mainIntro.exit()
    @mainIntro.start()

    @mainIntro.onhintclose (hintId) ->
      switch hintId
        when 0 then self.initValueOutputTour()
        when 1 then self.initOutputQualityTour()
