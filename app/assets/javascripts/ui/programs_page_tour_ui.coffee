class ProgramsPageTour.UI
  constructor: (tourAPI) ->
    @tourAPI = tourAPI
    @mainIntro = introJs()
    @createProgramsModalIntro = introJs()
    @createProgramsModalTour = introJs()
    @viewOneProgram = introJs()
    @takeTourAgainHint = introJs()
    @tourContent = {}
    @hintsOnPage = 0


  reduceIntroZIndex: ->
    $(".introjs-overlay").css("z-index", 100)
    $(".introjs-helperLayer").css("z-index", 100)

  reduceHintZIndex: (hint, hintPosition) ->
    { bottom } = $(".program-table-header-wrapper")[0].getBoundingClientRect()
    if bottom + window.pageYOffset > hintPosition
      hint.css('z-index', '-1')
    else
      hint.css('z-index', 'unset')

  handleScroll: =>
    if $(".edit-icon").length
      editIconTopPosition = $(".edit-icon")[0].getBoundingClientRect().top + window.pageYOffset
    viewIconTopPosition = $(".action-data span.view-icon")[0].getBoundingClientRect().top + window.pageYOffset
    $(".introjs-hint[data-step='1']").css('top', "#{viewIconTopPosition}px")
    $(".introjs-hint[data-step='2']").css('top', "#{editIconTopPosition}px")

    @reduceHintZIndex($(".introjs-hint[data-step='2']"), editIconTopPosition)
    @reduceHintZIndex($(".introjs-hint[data-step='1']"), viewIconTopPosition)

  reduceHelperLayer: ->
   $(".introjs-helperLayer").css("opacity", "0.5")
   $(".introjs-overlay").css("opacity", "0.2")

  closeTourModalOnTourFinish: (modalId, closeBtnClass) ->
    $("#{modalId} #{closeBtnClass}").click()

  takeThisTourAgainHint: ->
    @takeTourAgainHint.removeHints();
    @takeTourAgainHint.setOptions({
      hints: @tourContent.takeThisTourAgainHint,
      hintButtonLabel: "Got it!",
    })
    @takeTourAgainHint.addHints()
    @takeTourAgainHint.showHints()
    $('.introjs-hint').css("z-index", 1000)

  initProgramView: ->
    self= @
    setTimeout(@reduceIntroZIndex, 10)
    $(".action-data span.view-icon").click()
    @viewOneProgram.setOptions({
      steps: @tourContent.programPageModalView,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      hidePrev: true,
      hideNext: true
    })
    @viewOneProgram.start()
    @viewOneProgram.onafterchange ->
      setTimeout(self.reduceHelperLayer, 10)
    $("#single-program-modal .single-program-close-button").off("click.intro").on "click.intro", =>
      if $(".introjs-tooltip").is(':visible')
        @viewOneProgram.exit()
    @viewOneProgram.onexit =>
      @closeTourModalOnTourFinish("#single-program-modal", ".single-program-close-button")
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );

  initCreateLearnerProgram: ->
    self = @
    setTimeout(@reduceIntroZIndex, 10)
    $(".create-new-program").click()
    @createProgramsModalIntro.setOptions({
      steps: @tourContent.createProgramsModalSteps,
      showStepNumbers: false,
      skipLabel: "Skip the Tour",
      hidePrev: true,
      hideNext: true
    })
    @createProgramsModalIntro.start()
    @createProgramsModalIntro.onafterchange ->
      setTimeout(self.reduceHelperLayer, 10)
    $("#create-program-modal .close-button").off("click.intro").on "click.intro", =>
      if $(".introjs-tooltip").is(':visible')
        @createProgramsModalIntro.exit()
    @createProgramsModalIntro.onexit =>
      @closeTourModalOnTourFinish("#create-program-modal", ".close-button")
      $("html, body").animate({ scrollTop: 0 }, "slow", () ->
        !self.hintsOnPage && self.takeThisTourAgainHint()
      );
    
  initProgramsPageTour: ->
    self = @
    $("#tour-icon").off("click").click ->
      self.startProgramsPageTour()
    @tourAPI.getUserTourStatus(pageUrl[1]).then (tourData) ->
      self.tourContent = tourData.content
      unless tourData.has_toured
        self.startProgramsPageTour()

  startProgramsPageTour: ->
    @mainIntro.removeHints()
    self = @
    @mainIntro.setOptions({
      steps: @tourContent.programsPageSteps,
      hints: @tourContent.programsPageHints,
      hintButtonLabel: "Click",
      showStepNumbers: false,
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
        $('.introjs-fullbutton').css('background': '#3359db', 'width': '50px')
        $('.introjs-nextbutton').text('Next →')

    @mainIntro.onafterchange ->
      if this._currentStep == 3
        setTimeout(self.reduceHelperLayer, 10)
    @mainIntro.oncomplete ->
      this.addHints()
      this.showHints()
      if $(".edit-icon").length then self.hintsOnPage = 3 else self.hintsOnPage = 2
      self.tourAPI.createTourEntry(pageUrl[1])
      $('.all-programs-table-container').off("scroll").scroll(self.handleScroll)
      $(window).scroll(self.handleScroll)
    @mainIntro.onexit ->
      self.tourAPI.createTourEntry(pageUrl[1])

    @mainIntro.onhintclose (hintId) ->
      self.hintsOnPage -= 1
      switch hintId
        when 0 then self.initCreateLearnerProgram()
        when 1 then self.initProgramView()
    @mainIntro.exit()
    @mainIntro.start()
    @mainIntro.goToStepNumber(1)
