class SurveyBuilderTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @questionTour = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @surveyShareModal = new Modal.App('#main-share-modal', 636, 636, 467, 467)
    @clickedHints = {0: false, 1: false, 2: false, 3: false }
    @hintsOnPage = 0

  initSurveyBuilderTour: ->
    $('.tour-trigger').off('click').click =>
      @startSurveyBuilderTour()

    @tourAPI.getUserTourStatus('survey_builder').then (tourData) => 
      @tourContent = tourData.content
      @startSurveyBuilderTour() unless tourData.has_toured

  startSurveyBuilderTour: ->
    self = @
    @clickedHints =  {0: false, 1: false, 2: false, 3: false }
    @mainIntro.removeHints()
    @tourAPI.createTourEntry('survey_builder')
    @mainIntro.setOptions({
      steps: @tourContent.surveyBuilderSteps
      hints: @tourContent.surveyBuilderHints
      scrollToElement: true
      scrollPadding: -100000000
      hintButtonLabel: "Click"
      hidePrev: true
      hideNext: true
      showStepNumbers: false
      hidePrev: true
      hideNext: true
      skipLabel: "Skip the Tour"
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
      this.showHints()
      self.tourAPI.createTourEntry('survey_builder')
      self.hintsOnPage = self.tourContent.surveyBuilderHints.length
      $(".setup-container.form").off("scroll").scroll ->
        if $(".setup-container.form").scrollTop()
          self.mainIntro.hideHints()
        else
          for hintId, hasClicked of self.clickedHints
            self.mainIntro.showHint(hintId) unless hasClicked

    @mainIntro.onhintclose (hintId)->
      switch hintId
        when 0 then self.initAddSurveyTitle()
        when 1 then self.initAddDescription()
        when 2 then self.initAddQuestion()
        when 3 then self.addNewQuestion()
        
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  reduceIntroZIndex: ->
    $(".introjs-helperLayer").css("z-index", "100")
    $(".introjs-overlay").css("z-index", 100)

  initAddSurveyTitle: ->
    self = @
    @clickedHints[0] = true
    $("#survey-2-title").val("Example Survey")
    self.hintsOnPage -= 1
    $("html, body").animate({ scrollTop: 0 }, "slow", () ->
      !self.hintsOnPage && self.takeThisTourAgainHint()
    );

  initAddDescription: ->
    self = @
    @clickedHints[1] = true
    $("#add-survey-description-btn").click()
    $("#survey-description").val("Test Description")
    self.hintsOnPage -= 1
    $("html, body").animate({ scrollTop: 0 }, "slow", () ->
      !self.hintsOnPage && self.takeThisTourAgainHint()
    );

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints()
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  addNewQuestion: ->
    self = @
    @clickedHints[3] = true
    $("#add-question-btn-0").click()
    self.hintsOnPage -= 1
    $("html, body").animate({ scrollTop: 0 }, "slow", () ->
      !self.hintsOnPage && self.takeThisTourAgainHint()
    );

  closeSurveyModal: (modalId) ->
    $("#{modalId} .close-share-modal").click()

  initAddQuestion: ->
    self = @
    @clickedHints[2] = true
    @questionTour.setOptions({
      steps: @tourContent.addQuestionSteps
      hidePrev: true
      hideNext: true
      showStepNumbers: false
      skipLabel: "Skip the Tour"
    })

    @questionTour.onchange ->
      if this._currentStep == 1
        self.surveyShareModal.close()

    @questionTour.onafterchange ->
      if this._currentStep >= 2
        setTimeout(self.reduceIntroZIndex, 10)
      if this._currentStep == 9
        self.surveyShareModal.close()
        $('.introjs-nextbutton').addClass("introjs-disabled")
      if this._currentStep == 10
        self.questionTour.exit()
        

    @questionTour.onbeforechange ->
      if this._currentStep == 2
        self.surveyShareModal.open()
      if this._currentStep == 7
        self.surveyShareModal.open()

    $("#main-share-modal .close-share-modal").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.questionTour.exit()
    
    @questionTour.onexit ->
      self.closeSurveyModal("#main-share-modal")
      self.hintsOnPage -= 1
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );
        
    @questionTour.start()

