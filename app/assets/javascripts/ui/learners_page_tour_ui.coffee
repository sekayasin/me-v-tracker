class LearnersPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @learnerTableFieldsIntro = introJs()
    @takeTourAgainHint = introJs()
    @addLearnersIntro = introJs()
    @addLfasIntro = introJs()
    @filtersIntro = introJs()
    @tourContent = {}
    @prevStep = 0
    @hintsOnPage = 0

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 100)
    $(".introjs-helperLayer").css("z-index", 100)

  reduceHelperLayer: ->
   $(".introjs-helperLayer").css("opacity", "0.5")
   $(".introjs-overlay").css("opacity", "0.2")

  initTableFieldsIntro: ->
    self = @
    $("#demo-menu-lower-left").click()
    @learnerTableFieldsIntro.setOptions({
      steps: @tourContent.tableFieldSteps,
      showStepNumbers: false,
      showBullets: false
      skipLabel: "Skip the Tour"
    })
    @learnerTableFieldsIntro.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
          !self.hintsOnPage && self.takeThisTourAgainHint()
        );

    @learnerTableFieldsIntro.start()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)


    $(".introjs-tooltip").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.learnerTableFieldsIntro.exit()

  handleIntroButtonClick: (intro, buttonId, nextStep) ->
    $(buttonId).one "click", ->
      unless intro._currentStep == nextStep - 1
        intro.goToStep(nextStep)

  initModalIntro: (details) ->
    { intro, addBtnId, introSteps, countrySelector, nextBtnId, prevBtnId, modalId } = details
    self = @
    $("#{addBtnId}").click()
    intro.setOptions({
      steps: introSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
      hidePrev: true,
      hideNext: true
    })
    intro.onchange ->
      if this._currentStep < 2
        self.handleIntroButtonClick(intro, "#{nextBtnId}", 3)
        if this._direction == "backward" || self.prevStep > this._currentStep
          $("#{prevBtnId}").click()
      else
        self.handleIntroButtonClick(intro, "#{prevBtnId}", 2)
        if this._direction == "forward" || self.prevStep < this._currentStep
          $("#{countrySelector}").click()
          $("#{nextBtnId}").click()
      self.prevStep = this._currentStep
    intro.onafterchange ->
      setTimeout(self.reduceIntroZIndex, 100)
    $("#{modalId} .close-button").one "click", ->
      if $(".introjs-tooltip").is(':visible')
        intro.exit()
    intro.onexit ->
      if $("#{modalId} .close-button").is(':visible')
        $("#{modalId} .close-button").click()
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );
    intro.start()

  initAddLearnersIntro: ->
    learnerIntroDetails = {
      intro: @addLearnersIntro,
      addBtnId: "#add-learner",
      introSteps: @tourContent.addLearnersSteps,
      countrySelector: ".country",
      nextBtnId: "#rightBtn",
      prevBtnId: "#leftBtn",
      modalId: "#add-learner-modal"
    }
    @initModalIntro(learnerIntroDetails)

  initAddLfasIntro: ->
    lfaIntroDetails = {
      intro: @addLfasIntro,
      addBtnId: "#add-lfa",
      introSteps: @tourContent.addLfasSteps,
      countrySelector: ".facilitator-country",
      nextBtnId: "#right_btn_facilitator",
      prevBtnId: "#left_btn_facilitator",
      modalId: "#add-facilitator-modal"
    }
    @initModalIntro(lfaIntroDetails)

  initFiltersIntro: ->
    self = @
    $(".filter-btn").click()
    @filtersIntro.setOptions({
      steps: @tourContent.filterSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour"
    })

    @filtersIntro.onexit ->
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

    @filtersIntro.start()

  initLearnersPageTour: ->
    self = @
    $(".tour-trigger").off("click").click ->
      self.startLearnersPageTour()
    @tourAPI.getUserTourStatus(pageUrl[1]).then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startLearnersPageTour()

  startLearnersPageTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.setOptions({
      steps: @tourContent.learnerTableSteps,
      hints: @tourContent.learnerPageHints,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      hintButtonLabel: "Click"
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
      if this._currentStep == 5
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      this.addHints()
      this.showHints()
      self.hintsOnPage = self.tourContent.learnerPageHints.length
      $(".learners-page-pane-vScroll").off("scroll").scroll
      self.tourAPI.createTourEntry(pageUrl[1])
    @mainIntro.onhintclose (hintId) ->
      self.hintsOnPage -= 1
      switch hintId
        when 0 then self.initTableFieldsIntro()
        when 1 then self.initAddLearnersIntro()
        when 2 then self.initAddLfasIntro()
        when 3 then self.initFiltersIntro()
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
