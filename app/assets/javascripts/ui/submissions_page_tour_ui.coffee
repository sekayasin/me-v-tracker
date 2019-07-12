class SubmissionsPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @submissionCardTour = introJs()
    @submissionsFilterTour = introJs()
    @takeTourAgainHint = introJs()
    @role = ""
    @tourContent = {}

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")
    
  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  initSubmissionsFilter: ->
    self = @
    @submissionsFilterTour.setOptions({
      steps: @tourContent.filterSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
      hidePrev: true,
      hideNext: true
    })

    @submissionsFilterTour.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        self.takeThisTourAgainHint()
      );

    @submissionsFilterTour.start()

  initSubmissionsPageTour: ->
    self = @
    $("#tour-icon").off("click").click ->
      self.startSubmissionsPageTour()
    @tourAPI.getUserTourStatus(pageUrl[1]).then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startSubmissionsPageTour()

  startSubmissionsPageTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.setOptions({
      steps: @tourContent.submissionCardsSteps,
      hints: @tourContent.submissionsPageHints,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
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

    @mainIntro.onafterchange ->
      if this._currentStep == 4
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      this.showHints()
      self.tourAPI.createTourEntry(pageUrl[1])

    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])

    @mainIntro.onhintclose () ->
      self.initSubmissionsFilter()

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
