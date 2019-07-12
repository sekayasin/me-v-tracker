class LearningEcosystemPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @week1OutputTour = introJs()
    @overViewTabTour = introJs()
    @phasesTabTour = introJs()
    @valuesAlignmentTour = introJs()
    @outPutQualityTour = introJs()
    @feedbackTour = introJs()
    @feedbackModalTour = introJs()
    @submissionModalTour = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 99)
    $(".introjs-helperLayer").css("z-index", 99)

  registerEventListener: ->
    self = @

# week 1 output tour
  initWeek1OutputTour: ->
    self = @
    $("#accordion-title-week-1").click()
    @week1OutputTour.setOptions({
      steps: @tourContent.week1OutputSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      hidePrev: true,
      hideNext: true
    })
    @week1OutputTour.hideHints()
    @week1OutputTour.start()

    @week1OutputTour.oncomplete ->
      this.showHint(1)
      $("#accordion-title-week-1").click()

# phases tab tour
  initPhasesTabTour: ->
    self = @
    @phasesTabTour.setOptions({
      steps: @tourContent.phasesTabTourSteps,
      hints: @tourContent.weeklyOutputsHints,
      showStepNumbers: false,
      hintButtonLabel: "Click",
      skipLabel: "Skip the Tour",
      hidePrev: true,
      hideNext: true
    })

    @mainIntro.exit()
    @phasesTabTour.start()

    @phasesTabTour.oncomplete ->
      this.addHints()
      this.showHint(2)
      self.mainIntro.exit()

    @mainIntro.hideHints()
    window.dispatchEvent(new Event('resize'));
    @phasesTabTour.onhintclose ->
      @mainIntro.hideHint()

# output Quality tour
  initOutputQualityTour: ->
    self = @
    $("#accordion-title-1").click()
    @outPutQualityTour.setOptions({
      steps: @tourContent.outPutQualityTourSteps,
      hints: @tourContent.weeklyOutputsHints,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      doneLabel: "Click",
      scrollToElement: true,
      scrollPadding: -1000000,
      hidePrev: true,
      hideNext: true
    })

    @outPutQualityTour.oncomplete ->
      $("#accordion-title-1").click()
    @outPutQualityTour.start()

    @outPutQualityTour.onexit ->
      $(".enter-submission-btn").click()
      self.initSubmissionModalTour()
      setTimeout(self.reduceIntroZIndex, 10)

# learner output submission modal tour
  initSubmissionModalTour: ->
    self = @
    $("#learner-output-submission").click()
    @submissionModalTour.setOptions({
      steps: @tourContent.submissionModalSteps,
      hints: @tourContent.weeklyOutputsHints,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      doneLabel: "Click",
      scrollToElement: true,
      scrollPadding: -1000000,
      hidePrev: true,
      hideNext: true
    })

    $("#close-learner-modal").click ->
      self.mainIntro.exit()

    @submissionModalTour.oncomplete ->
      $("#learner-output-submission").click()

    @submissionModalTour.start()

    @submissionModalTour.onafterchange ->
      setTimeout(self.reduceHelperLayer, 10)

    @submissionModalTour.onexit ->
      $("#close-learner-modal").click()
      self.takeThisTourAgainHint()
      

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint
      hintButtonLabel: "Got it!"
      scrollToElement: true
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)


# learning ecosystem page tour
  initLearningEcosystemPageTour: ->
    self = @
    @registerEventListener()
    $("#tour-icon").off("click").click ->
      if $("#phases-tab").hasClass("is-active")
        $("#phases-tab, #phases-panel").removeClass("is-active")
        $("#overview-tab, #overview-panel").addClass("is-active")
      self.startLearningEcosystemPageTour()
    @tourAPI.getUserTourStatus(pageUrl[2]).then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startLearningEcosystemPageTour()

  startLearningEcosystemPageTour: () ->
    self =  @
    @mainIntro.removeHints()
    @tourAPI.createTourEntry("ecosystem")
    @mainIntro.setOptions({
      steps: @tourContent.learningEcosystemPageSteps,
      hints: @tourContent.weeklyOutputsHints,
      showStepNumbers: false,
      hintButtonLabel: "Click",
      skipLabel: "Skip the Tour",
      hidePrev: true,
      hideNext: true
    })

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')
      if this._currentStep == 11
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      this.addHints()
      this.showHint(0)
      this.showHint(1)
      self.tourAPI.createTourEntry(pageUrl[2])
      $("#phases-tab").click =>
        this.removeHint(0)

    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.onhintclose (hintId) ->
      switch hintId
        when 0
          self.initWeek1OutputTour()
        when 1
          $("#phases-tab b").click()
          interval = setInterval (->
            unless $('.main-content').hasClass('loading')
              self.initPhasesTabTour()
              clearInterval(interval)
          ), 500
        when 2
          self.initOutputQualityTour()


