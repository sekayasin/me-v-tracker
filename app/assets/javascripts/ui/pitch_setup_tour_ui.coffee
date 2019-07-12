class Pitch.PitchSetupTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @showMoreOptionsTour = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @hintsOnPage = 0
    @pitchSetupTourModal = new Modal.App('#pitch-setup-tour-modal', 672, 672, 598, 598)

  initPitchSetupTour: ->
    if pageUrl[1] == 'pitch' and !pageUrl[2]
      @registerEventListeners()
      $('.tour-trigger').off('click').click =>
        @startPitchSetupTour()

      @tourAPI.getUserTourStatus('pitch_setup').then (tourData) =>
        @tourContent = tourData.content
        unless tourData.has_toured
          @pitchSetupTourModal.open()

  registerEventListeners: ->
    self = @
    $('#pitch-setup-tour-button').click ->
      self.pitchSetupTourModal.close()
      self.startPitchSetupTour()

     $('#skip-tour-btn').click ->
      self.pitchSetupTourModal.close()
      self.tourAPI.createTourEntry('pitch_setup')

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startPitchSetupTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('pitch_setup')
    if $('.empty-pitch').length
      steps = @tourContent.pitchSetupSteps.filter (step) ->
        step.element != '.pitch-card'
    else
      steps = @tourContent.pitchSetupSteps
    @mainIntro.setOptions({
      steps
      hints: @tourContent.pitchSetupHints
      hidePrev: true
      hideNext: true
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      skipLabel: "Skip the Tour"
      hintButtonLabel: "Got it!"
    })

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.onafterchange ->
      if this._currentStep == 7
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      this.addHints()
      this.showHints()
      if $(".introjs-hint").length > 1
        self.hintsOnPage = self.tourContent.pitchSetupHints.length
      else
        self.takeThisTourAgainHint()

    @mainIntro.onhintclose (hintId) ->
      self.hintsOnPage -= 1
      self.initShowMoreOptions()
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.hideHints()


  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  reduceIntroZIndex: ->
    $(".introjs-helperLayer").css("z-index", 99)
    $(".introjs-overlay").css("z-index", 100)

  initShowMoreOptions: ->
    self = @
    @showMoreOptionsTour.setOptions({
      steps: @tourContent.moreOptionsSteps
      showStepNumbers: false
      disableInteraction: true
      skipLabel: "Skip the Tour"
    })

    @showMoreOptionsTour.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      )

    @showMoreOptionsTour.start()
