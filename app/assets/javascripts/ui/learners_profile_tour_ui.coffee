class LearnerProfileTour.UI
  constructor: (tourAPI) -> 
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @personalDetailsTour = introJs()
    @technicalDetailsTour = introJs()
    @tourContent = {}
    @takeTourAgainHint = introJs()
    @learnersProfileTourModal = new Modal.App('#learners-profile-tour-modal', 636, 636, 467, 467)
    @hintsOnPage = 0

  initLearnersProfileTour: ->
    self = @
    @registerEventListeners()
    $('.tour-trigger').off('click').click ->
      self.startLearnerProfileTour()
    @tourAPI.getUserTourStatus('learner_profile').then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.learnersProfileTourModal.open()
  
  registerEventListeners: ->
    self = @
    $('#learners-profile-tour-button').click ->
      self.learnersProfileTourModal.close()
      self.startLearnerProfileTour()
      self.mainIntro.goToStepNumber(2)

    $('#skip-tour-btn').click ->
      self.learnersProfileTourModal.close()
      self.tourAPI.createTourEntry('learner_profile')
  
  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)
  
  cleanUpAndCloseModal: (modalId) ->
    $("#{modalId} .close-button").click()
    
  startLearnerProfileTour: ->
    self =  @
    @mainIntro.removeHints()
    @tourAPI.createTourEntry('learner_profile')
    @mainIntro.setOptions({
      steps: @tourContent.learnersProfileSteps
      hints: @tourContent.learnersProfileHints
      hidePrev: true
      hideNext: true
      scrollToElement: true
      scrollTo: "element"
      hintButtonLabel: "Click"
      showStepNumbers: false
      skipLabel: "Skip the Tour"
    })

    @mainIntro.onchange ->
      if this._currentStep == 0
        $('.introjs-fullbutton').css({'background': '#4aa071', 'width': '100px'})
        $('.introjs-fullbutton').text('Get Started')
      else if this._currentStep != 0
        $('.introjs-nextbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')
      if this._currentStep == 3
        setTimeout(self.reduceHelperLayer, 10)

    @mainIntro.oncomplete ->
      $("html, body").animate({ scrollTop: 0 }, "slow");
      this.addHints()
      this.showHints()
      self.hintsOnPage = self.tourContent.learnersProfileHints.length

    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.onhintclose (hintId)->
      self.hintsOnPage -= 1
      switch hintId
        when 0 then self.initEditPersonalDetails()
        when 1 then self.initEditTechnicalDetails()
  
  initEditPersonalDetails: ->
    self = @
    $("#edit-personal-details-button").click()
    @personalDetailsTour.setOptions({
      steps: @tourContent.editPersonalDetailsSteps
      showStepNumbers: false
      showBullets: false
      skipLabel: "Skip the Tour"
    })
    
    $("#edit-personal-details-modal .close-button").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.personalDetailsTour.exit()

    @personalDetailsTour.onexit ->
      self.cleanUpAndCloseModal("#edit-personal-details-modal")
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );


    @personalDetailsTour.start()

    setTimeout(self.reduceIntroZIndex, 2)
  
  initEditTechnicalDetails: ->
    self = @
    $("#edit-technical-details-button").click()
    @technicalDetailsTour.setOptions({
      steps: @tourContent.editTechnicalDetailsSteps
      showStepNumbers: false
      showBullets: false
      skipLabel: "Skip the Tour"
    })

    $("#edit-learner-technical-details-modal .close-button").off("click.intro").on "click.intro", ->
      if $(".introjs-tooltip").is(':visible')
        self.technicalDetailsTour.exit()
    
    @technicalDetailsTour.onexit ->
      self.cleanUpAndCloseModal("#edit-learner-technical-details-modal")
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

    @technicalDetailsTour.start()

    setTimeout(self.reduceIntroZIndex, 2)

  reduceHelperLayer: ->
    $(".introjs-helperLayer").css("opacity", "0.5")
    $(".introjs-overlay").css("opacity", "0.5")

  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 100)
    $(".introjs-helperLayer").css("z-index", 100)
