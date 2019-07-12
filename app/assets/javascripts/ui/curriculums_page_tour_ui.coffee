class CurriculumsPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @programDetailsTour = introJs()
    @learningOutComes = introJs()
    @takeTourAgainHint = introJs()
    @criteria = introJs()
    @framework = introJs()
    @tourContent = {}
    @hintsOnPage = 0

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 99)
    $(".introjs-helperLayer").css("z-index", 99)

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  initLearningOutcomes:  ->
    self = @
    $(".mdl-tabs__tab:eq(2) span").click()
    @learningOutComes.setOptions(
      steps: @tourContent.learningOutcomesSteps,
      showStepNumbers: false,
      hidePrev: true,
      hideNext: true,
      hintButtonLabel: "Click",
    skipLabel: "Skip the Tour"
    )
    @learningOutComes.onchange ->
      if this._currentStep == 2 || this._currentStep == 3
       $("html, body").animate({ scrollTop: 0 }, "slow");
    @learningOutComes.start()
    @learningOutComes.oncomplete ->
     $(".mdl-tabs__tab:eq(3) span").click()


    @learningOutComes.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );


  initCriteria: ->
    self = @
    $(".mdl-tabs__tab:eq(1) span").click()
    @criteria.setOptions(
      steps: @tourContent.criteriaSteps,
      showStepNumbers: false,
      hidePrev: true,
      hideNext: true,
      skipLabel: "Skip the Tour"
    )
    @criteria.start()
    @criteria.oncomplete ->
     $(".mdl-tabs__tab:eq(3) span").click()

    @criteria.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );


  initFramework: ->
    self = @
    $(".mdl-tabs__tab:eq(0) span").click()
    @framework.setOptions(
      steps: @tourContent.frameworkSteps,
      showStepNumbers: false,
      hidePrev: true,
      hideNext: true,
      skipLabel: "Skip the Tour"
    )
    @framework.start()

    @framework.oncomplete ->
      $(".mdl-tabs__tab:eq(3) span").click()
    
    @framework.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

  initCurriculumsPageTour: ->
    self = @
    $(".tour-trigger").off("click").click ->
      $(".mdl-tabs__tab:eq(3) span").click()
      self.startCurriculumsPageTour()
    @tourAPI.getUserTourStatus(pageUrl[1]).then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startCurriculumsPageTour()

  startCurriculumsPageTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.setOptions({
      steps: @tourContent.programDetailsSteps,
      hints: @tourContent.curriculumPageHints,
      hidePrev: true,
      hideNext: true,
      scrollToElement: true
      scrollPadding: -100000000
      hintButtonLabel: "Click"
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
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
      self.hintsOnPage = self.tourContent.curriculumPageHints.length
      self.tourAPI.createTourEntry(pageUrl[1])
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])
    @mainIntro.onhintclose (hintId) ->
      self.hintsOnPage -= 1
      switch hintId
        when 0 then self.initLearningOutcomes()
        when 1 then self.initCriteria()
        when 2 then self.initFramework()
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
