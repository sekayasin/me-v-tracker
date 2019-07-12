class Pitch.PitchPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @takeTourAgainHint = introJs()
    @panelistTabHint = introJs()
    @learnersTabHint = introJs()
    @tourContent = {}
    @pitchPageTourModal = new Modal.App('#pitch-page-tour-modal', 672, 672, 598, 598)

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 99)
    $(".introjs-helperLayer").css("z-index", 99)

  registerEventListeners: ->
    self = @
    $('#skip-tour-btn').click ->
      self.pitchPageTourModal.close()
      self.tourAPI.createTourEntry('pitch')

    $('#pitch-page-tour-button').click ->
      self.pitchPageTourModal.close()
      self.startPitchPageTour()

  initPitchPageTour: ->
    self = @
    if pageUrl[1] == 'pitch' and !isNaN(pageUrl[2])
      @registerEventListeners()

      $('.tour-trigger, .mobile-tour').off("click").click ->
        self.startPitchPageTour()

      @tourAPI.getUserTourStatus('pitch').then (tourData) ->
        self.tourContent = tourData.content
        unless tourData.has_toured
          self.pitchPageTourModal.open()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint
      hintButtonLabel: "Got it!"
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startPitchPageTour: () ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()

    steps = @tourContent.pitchPageTourSteps

    if $('#panellists-panel.is-active').length
      steps = steps.filter (step) ->
        step.element != '.learner-pitch-tab-card' &&
        step.element != '.learner-pitch-tab-card .persona-badge' &&
        step.element != '#learners-panel .invite-report'
    else if $('#learners-panel.is-active').length
      steps = steps.filter (step) ->
        step.element != '#panellists-pitch-grid .pitch-persona-card' &&
        step.element != '#panellists-panel .invite-report'

    unless $('#learners-pagination .main-pages').length
      steps = steps.filter (step) ->
        step.element != '#learners-pagination .main-pages'

    @mainIntro.setOptions({
      steps
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      hintButtonLabel: "Got it!"
      skipLabel: "Skip the Tour"
      hidePrev: true
      hideNext: true
    })

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({ 'background': '#4aa071', 'width': '100px' })
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css({ 'background': '#3359db', 'width': '50px' })
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.onafterchange ->
      if this._currentStep == 7
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      self.tourAPI.createTourEntry('pitch')
      if $('#panellists-tab').length and $('#learners-panel.is-active').length
        self.showPanelistTabHint()
      else if $('#learners-tab').length and $('#panellists-panel.is-active').length
        self.showLearnersTabHint()
      else
        self.takeThisTourAgainHint()

    @mainIntro.onexit ->
      self.tourAPI.createTourEntry('pitch')

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.hideHints()

  showPanelistTabHint: ->
    self = @
    @panelistTabHint.removeHints()
    @panelistTabHint.setOptions({
      hints: @tourContent.panelistsTabHint
      hintButtonLabel: "Got it!"
    })
    @panelistTabHint.addHints()
    @panelistTabHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

    @panelistTabHint.onhintclose ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        self.takeThisTourAgainHint()
      )

    @panelistTabHint.start()

  showLearnersTabHint: ->
    self = @
    @learnersTabHint.removeHints()
    @learnersTabHint.setOptions({
      hints: @tourContent.learnersTabHint
      hintButtonLabel: "Got it!"
    })
    @learnersTabHint.addHints()
    @learnersTabHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

    @learnersTabHint.onhintclose ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        self.takeThisTourAgainHint()
      )

    @learnersTabHint.start()
