class UserAnalyticsTour.UI
  constructor: (@tourAPI) ->
    @mainIntro = introJs()
    @cycleMetricsIntro = introJs()
    @programFeedbackIntro = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @analyticsTourModal = new Modal.App('#analytics-tour-modal', 636, 636, 467, 467)
    @hintsOnPage = 0

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 100)
    $(".introjs-helperLayer").css("z-index", 100)

  waitForLoadingScreen: ->
    self = @
    interval = setInterval ( ->
      unless $('.main-content').hasClass('loading')
        self.initAnalyticsPageTour()
        clearInterval(interval)
    ), 500

  initAnalyticsPageTour: ->
    self = @
    @registerEventListener()
    $(".tour-trigger").off("click").click ->
      $('#cycle-metrics-tab, #cycle-metrics-panel, #program-feedback-tab, #program-feedback-panel').removeClass('is-active')
      $('#program-metrics-tab, #program-metrics-panel').addClass('is-active')
      $('#program-metrics-tab').click()
      self.startAnalyticsPageTour()

    @tourAPI.getUserTourStatus(pageUrl[1]).then (tourResult) ->
      self.tourContent = tourResult.content
      unless tourResult.has_toured
        self.analyticsTourModal.open()
  
  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)


  registerEventListener: ->
    self = @
    $('#analytics-tour-button').click ->
      self.analyticsTourModal.close()
      self.startAnalyticsPageTour()
      self.mainIntro.goToStepNumber(2)

    $('#skip-tour-btn').click ->
      self.tourAPI.createTourEntry(pageUrl[1])
      self.analyticsTourModal.close()

  initCycleMetricsIntro: ->
    self = @
    @cycleMetricsIntro.setOptions({
      steps: @tourContent.cycleMetricsSteps,
      hidePrev: true,
      hideNext: true
      showStepNumbers: false
      skipLabel: "Skip the Tour"
    })

    @cycleMetricsIntro.onchange ->
      if this._currentStep == 0
        $('#center-dropdown-button').css('background', 'white')
      else if this._currentStep == 4
        $('#cycle-dropdown-button').css('background', 'white')
      else 
        $('#center-dropdown-button, #cycle-dropdown-button').css('background', 'transparent')

    @cycleMetricsIntro.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

    @cycleMetricsIntro.start()

  initProgramFeedbackIntro: ->
    self = @
    @programFeedbackIntro.setOptions({
      steps: @tourContent.programFeedbackSteps,
      hidePrev: true,
      hideNext: true
      showStepNumbers: false
      skipLabel: "Skip the Tour"
    })

    @programFeedbackIntro.onchange ->
      if this._currentStep == 0
        $('#program-feedback-center-dropdown-button').css('background', 'white')
      else if this._currentStep == 1
        $('#program-feedback-cycle-dropdown-button').css('background', 'white')
      else 
        $('#program-feedback-center-dropdown-button, #program-feedback-cycle-dropdown-button').css('background', 'transparent')

    @programFeedbackIntro.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

      
    @programFeedbackIntro.start()

  startAnalyticsPageTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.setOptions({
      steps: @tourContent.analyticsTableSteps,
      scrollToElement: true,
      hints: @tourContent.analyticsPageHints,
      hidePrev: true,
      hideNext: true,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      hintButtonLabel: "Click"
    })    

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-fullbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-fullbutton').text('Next →')
      if this._currentStep == 2
        $('#select_start_date').css('background', 'white')
      else if this._currentStep == 3
        $('#select_end_date').css('background', 'white')
      else 
        $('#select_start_date, #select_end_date').css('background', 'transparent')

    @mainIntro.oncomplete ->
      $("html, body").animate({ scrollTop: 0 }, "slow");
      this.addHints()
      this.showHints()
      self.hintsOnPage = self.tourContent.analyticsPageHints.length
      self.tourAPI.createTourEntry(pageUrl[1])
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])

    @mainIntro.onhintclose (hintId) ->
      self.hintsOnPage -= 1
      switch hintId
        when 0
          $('#program-metrics-tab, #program-metrics-panel, #program-feedback-tab, #program-feedback-panel').removeClass('is-active')
          $('#cycle-metrics-tab, #cycle-metrics-panel').addClass('is-active')
          $('#cycle-metrics-tab').click() 
          self.initCycleMetricsIntro()
        when 1 
          $('#cycle-metrics-tab, #cycle-metrics-panel, #program-metrics-tab, #program-metrics-panel').removeClass('is-active')
          $('#program-feedback-tab, #program-feedback-panel').addClass('is-active')
          $('#program-feedback-tab').click()
          setTimeout( -> 
            self.initProgramFeedbackIntro()
          , 500)
    
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
