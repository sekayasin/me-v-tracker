class Pitch.PitchRateLearnerTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @instructionModalTour = introJs()
    @previewModalTour = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  registerEventListeners: ->
    self = @
    $('.tour-trigger').off("click").click ->
      self.startPitchRateLearnerTour()
    $('#skip-tour-btn').click ->
      self.tourAPI.createTourEntry('pitch_rate_learner')

  initPitchRateLearnerTour: ->
    self = @
    self.registerEventListeners()

    @tourAPI.getUserTourStatus('pitch_rate_learner').then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        $('#continue-btn').click ->
            self.startPitchRateLearnerTour()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint
      hintButtonLabel: "Got it!"
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startPitchRateLearnerTour: () ->
    self =  @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    @tourAPI.createTourEntry('pitch_rate_learner')

    @mainIntro.setOptions({
      steps: @tourContent.pitchRateLearnerSteps
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      hintButtonLabel: "Got it!"
      skipLabel: "Skip the Tour"
      hidePrev: true
      hideNext: true
    })

    @mainIntro.onafterchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.onchange ->
      if this._currentStep == 6
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        self.takeThisTourAgainHint()
      )

    @mainIntro.start()
