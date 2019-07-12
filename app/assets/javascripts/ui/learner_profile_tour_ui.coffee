class LearnersProfileTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @programHistoryTour = introJs()
    @decisionHistoryTour = introJs()
    @editProfileTour = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @isClicked = false
    @hintsOnPage = 0

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 100)
    $(".introjs-helperLayer").css("z-index", 99)

  cleanUpAndCloseModal: (modalId) ->
    self.hasNext = false
    self.hasPrev = false
    $("#{modalId} .close-button").click()

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.2")

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  initProgramHistoryTour: ->
    self = @
    $("#program-history-view").click()
    @programHistoryTour.setOptions({
      steps: @tourContent.programModalSteps
      showStepNumbers: false
      showBullets: false
    })

    $(".program-history-modal .close-button").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.programHistoryTour.exit()

    @programHistoryTour.onexit ->
      self.hintsOnPage -= 1
      self.cleanUpAndCloseModal(".program-history-modal")
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

    @programHistoryTour.start()

    setTimeout(self.reduceIntroZIndex, 10)

  initDecisionHistoryTour: ->
    self = @
    $("#decision-history-view").click()
    @decisionHistoryTour.setOptions({
      steps: @tourContent.decisionModalSteps
      showStepNumbers: false
      showBullets: false
    })

    $("#decision-history-modal .close-button").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.decisionHistoryTour.exit()

    @decisionHistoryTour.onexit ->
      self.cleanUpAndCloseModal("#decision-history-modal")
      self.hintsOnPage -= 1
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

    @decisionHistoryTour.start()

    setTimeout(self.reduceIntroZIndex, 10)

  initEditProfileTour: ->
    self = @
    @isClicked = true
    $(".edit-learner-icon").click()
    @editProfileTour.setOptions({
      steps: @tourContent.editProfileSteps
      showStepNumbers: false
      showBullets: false
    })

    $(".edit-learner-bio-info-modal .close-button").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.editProfileTour.exit()

    @editProfileTour.onexit ->
      $(".introjs-hint").eq(2).hide()
      self.cleanUpAndCloseModal(".edit-learner-bio-info-modal")
      self.hintsOnPage -= 1
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

    @editProfileTour.start()

    setTimeout(self.reduceIntroZIndex, 10)

  initLearnerProfileTour: ->
    self = @
    $(".tour-trigger").off("click").click ->
      self.startLearnersProfilePageTour()
    @tourAPI.getUserTourStatus("learner-profile").then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startLearnersProfilePageTour()

  startLearnersProfilePageTour: ->
    self = @
    @mainIntro.removeHints()
    @tourAPI.createTourEntry("learner-profile")

    @mainIntro.setOptions({
      steps: @tourContent.learnerProfileSteps
      hints: @tourContent.learnerProfileHints
      scrollToElement: true
      scrollPadding: -100000000
      hintButtonLabel: "Click"
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

    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])

    @mainIntro.onafterchange ->
      if this._currentStep == 10
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      this.addHints()
      this.showHints()
      self.hintsOnPage = self.tourContent.learnerProfileHints.length
      if true
        $(document).scroll ->
          position = $(".edit-learner-icon").get(0).getBoundingClientRect()
          { left, top } = position
          elementAtPosition = $(document).get(0).elementFromPoint(left, top)
          if $(elementAtPosition).parents(".header-container").length || elementAtPosition == null || self.isClicked
            $(".introjs-hint").eq(2).hide()
          else
            $(".introjs-hint").eq(2).show()

    @mainIntro.onhintclose (hintId) ->
      switch hintId
        when 0 then self.initProgramHistoryTour()
        when 1 then self.initDecisionHistoryTour()
        when 2 then self.initEditProfileTour()

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
