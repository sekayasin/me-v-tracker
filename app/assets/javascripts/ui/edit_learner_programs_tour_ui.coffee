class EditLearnerProgramsTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @tourContent = {}
    @takeTourAgainHint = introJs()

  initEditLearnerProgramsTour: ->
    self = @
    $("#tour-icon").off("click").click ->
      self.startEditProgramsPageTour()
    @tourAPI.getUserTourStatus("#{pageUrl[1]}-edit").then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startEditProgramsPageTour()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  startEditProgramsPageTour: ->
    self = @
    @mainIntro.removeHints()
    @mainIntro.setOptions({
      steps: @tourContent.EditLearnerProgramsSteps,
      showStepNumbers: false,
      hints: @tourContent.editProgramsPageHints,
      hintButtonLabel: "Click",
      skipLabel: "Skip the Tour",
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
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry("#{pageUrl[1]}-edit")
      this.addHints()
      $("[data-open*='8-dropdown']")[0].scrollIntoView({block: "center"})
    @mainIntro.onhintclose ->
      $("[data-open*='8-dropdown']").click()
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );
