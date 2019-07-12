class SurveyTableTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @showMoreOptionsTour = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @hintsOnPage = 0

    @previewModalTour = introJs()
    @tourContent = {}
    @surveyStatus = ""
    @surveyPreviewModal = new Modal.App('#survey-v2-preview-modal', 672, 672, 598, 598)

  initSurveyTableTour: ->
    $('.tour-trigger').off('click').click =>
      @startSurveyTableTour()

    @tourAPI.getUserTourStatus('survey-table').then (tourData) =>
      @tourContent = tourData.content
      @startSurveyTableTour() unless tourData.has_toured

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startSurveyTableTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.hideHints()
    $(".introjs-hints a:nth-child(2)").hide()
    @tourAPI.createTourEntry('survey-table')
    if $('.empty-survey').length 
      steps = @tourContent.surveyTableSteps.filter (step) -> 
        step.element != '.survey-card' &&
        step.element != '.learners-survey-card'
    else
      steps = @tourContent.surveyTableSteps
    @mainIntro.setOptions({
      steps
      hints: @tourContent.surveyTableHints
      hidePrev: true
      hideNext: true
      scrollToElement: true
      scrollPadding: -100000000
      showStepNumbers: false
      skipLabel: "Skip the Tour"
      hintButtonLabel: "Click"
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
        self.hintsOnPage = self.tourContent.surveyTableHints.length
      else
        self.takeThisTourAgainHint()
      $(".introjs-hints a:nth-child(2)").hide()


    @mainIntro.onhintclose (hintId)->
      self.hintsOnPage -= 1
      if hintId == 0
        self.initShowMoreOptions()
      else if hintId == 1
        $('.survey-card-body').eq(0).trigger("click")
        $(".introjs-hints a:nth-child(2)").hide()
        setTimeout( -> 
          self.initPreviewModal()
        , 500)
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
      );
    @showMoreOptionsTour.oncomplete ->
      $(".introjs-hints a:nth-child(2)").show()

    @showMoreOptionsTour.start()

  initPreviewModal: ->
    self = @
    @surveyStatus = $('.survey-status').eq(0).text()
    previewSteps = @tourContent.surveyPreviewModalSteps
    if @surveyStatus == "Published" && previewSteps.length < 5
      previewSteps.splice(1, 0, {
        "element": ".title-right",
        "intro": "You can make a survey accept responses by toggling this button on or off."
      })

      if $('#view_responses').css('display') == 'none'
        previewSteps = previewSteps.filter (step) -> step.element != '#view_responses'

    else if @surveyStatus == "Draft" && previewSteps.length > 4
      previewSteps.splice(1, 1)

    @previewModalTour.setOptions({
      steps: previewSteps
      showStepNumbers: false
      hidePrev: true
      hideNext: true
      skipLabel: "Skip the Tour"
    })

    $("#preview-close").click ->
      self.previewModalTour.exit()

    @previewModalTour.oncomplete ->
      self.surveyPreviewModal.close()

    @previewModalTour.onexit ->
      self.surveyPreviewModal.close()
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        self.takeThisTourAgainHint()
      );

    @previewModalTour.start()
