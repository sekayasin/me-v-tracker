class ProgramEdit.UI
  constructor: (@submitProgramDetails, @programId, @sendAdminNotification) ->
    @currentPhaseIndex = 0
    @activateOptionDropdownLinks()
    @activateOptionDropdown()
    @activateImplicitDropdownClose()
    @activateHolisticEvaluationChange()
    @activateHolisticEvaluationDurationLimit()
    @activateCheckboxDropdownLinks()
    @activateEditCancel()
    @activateConfirmSaveModal()
    @activateCheckboxGroups()
    @activateAssessmentChange()
    @activatePhaseAdd()
    @activateProgramSubmit()
    @activateAddNewPhase()
    @activateNameAndDescriptionErrorSignals()

  activateImplicitDropdownClose: () =>
    $(window).on 'click', (event) =>
      unless event.target.closest('.select-group-wrapper')
        $('.options-dropdown').each (i, element) => @closeOptionDropdown $(element)
        $('.open-option-dropdown').find('.icon-background').removeClass('option-icon-up')

  closeOptionDropdownIcon: (dropdown) =>
    dropdownIcon = dropdown.prev().find '.icon-background'
    if dropdown.is ':visible' then dropdownIcon.addClass 'option-icon-up' else dropdownIcon.removeClass 'option-icon-up'

  closeOptionDropdown: (dropdown) =>
    dropdown.hide()
    @closeOptionDropdownIcon dropdown

  closeOtherOptionDropdowns: (currentDropdown) =>
    $('.options-dropdown').each (i, element) =>
      dropdown = $(element)
      @closeOptionDropdown dropdown unless dropdown.is(currentDropdown)

  toggleOptionDropdown: (event) =>
    currentTarget = $(event.currentTarget)
    dropdown = $("##{currentTarget.data("open")}")
    @closeOtherOptionDropdowns dropdown
    dropdown.toggle()
    currentTarget.find('.icon-background').toggleClass('option-icon-up')
    currentTarget.toggleClass('option-icon-up') if currentTarget.hasClass("icon-background")

  activateOptionDropdownLinks: () =>
    $('.open-option-dropdown').on 'click', (event) => @toggleOptionDropdown event

  activateHolisticEvaluationChange: () =>
    $('#evaluation-input').on 'holisticEvaluationChange', () =>
      if $('#evaluation-input').text() is 'Yes'
        $('#evaluation-duration').show()
      else
        $('#evaluation-duration').hide()

  activateHolisticEvaluationDurationLimit: () =>
    durationInput = $('#evaluation-duration').find("input")
    durationInput.on("blur", (event) =>
      durationInput.val(1) if event.currentTarget.value < 1
    )

  activateOptionDropdown: () =>
    $('.options-dropdown').each (i, element) =>
      dropdown = $(element)
      input = $("##{element.id}-input")
      dropdown.find('li').on 'click', (event) =>
        value = event.target.innerText
        input.val value
        input.text value
        $('#evaluation-input').trigger 'holisticEvaluationChange'
        dropdown.toggle()
        @closeOptionDropdownIcon dropdown

  changeCheckboxDropdownIcon: (dropdown) =>
    dropdownIcon = dropdown.prev()
    if dropdown.is ':visible' then dropdownIcon.addClass 'expanded' else dropdownIcon.removeClass 'expanded'

  closeCheckboxDropdown: (dropdown) =>
    dropdown.hide()
    @changeCheckboxDropdownIcon(dropdown)

  closeOtherCheckboxDropdowns: (currentDropdown) =>
    $('.checkbox-dropdown').each (i, element) =>
      dropdown = $(element)
      @closeCheckboxDropdown dropdown unless dropdown.is(currentDropdown)

  toggleCheckboxDropdown: (event) =>
    dropdown = $("##{event.currentTarget.dataset.open}")
    @closeOtherCheckboxDropdowns dropdown
    dropdown.toggle()
    @changeCheckboxDropdownIcon(dropdown)

  activateCheckboxDropdownLinks: (event) =>
    $('.open-checkbox-dropdown').on 'click', (event) => @toggleCheckboxDropdown event

  activateNameAndDescriptionErrorSignals: () =>
    $("#program-description").on("keyup", (event) =>
      if $(event.currentTarget).val()
        $("#description-required").removeClass("error-mode")
      else
        $("#description-required").addClass("error-mode")
    )
    $("#program-name").on("keyup", (event) =>
      if $(event.currentTarget).val()
        $("#name-required").removeClass("error-mode")
      else
        $("#name-required").addClass("error-mode")
    )

  validateDetails: () =>
    valid = true
    programName = $("#program-name").val()
    programDescription = $("#program-description").val()
    phasePills = $(".phase-pill")
    valid = !!programName and !!programDescription and !!phasePills.length
    valid || scrollTo(0, 0)
    return valid

  activateEditCancel: () =>
    $("#cancel-program-edit").on('click', () =>
      programId = localStorage.getItem("programId")
      window.location.href = "/learners?program_id=#{programId}"
    )

  activateConfirmSaveModal: () =>
    $('#open-confirm-save-modal').on 'click', () =>
      if @validateDetails()
        $('#confirm-save-modal').addClass('confirm-save-modal-open')
    $('#close-confirm-save-modal').on 'click', () =>
      $('#confirm-save-modal').removeClass('confirm-save-modal-open')

  activateCheckboxGroups: () =>
    $(".checkbox-group").on 'click', (event) =>
      $(event.currentTarget).find("input[type=checkbox]").trigger("click")

  activateAssessmentChange: () =>
    $(".small-checkbox").on("click", (event) =>
      event.stopPropagation()
      assessmentId = parseInt(event.currentTarget.dataset.assessment_id)
      checked = event.currentTarget.checked
      phase = @phases[@currentPhaseIndex]
      if checked
        phase.assessments.push(assessmentId)
      else
        assessments = phase.assessments
        assessmentIndex = assessments.findIndex((item) => item is assessmentId)
        assessments.splice(assessmentIndex, 1)
    )

  setCurrentPhaseIndex: (phaseIndex) => @currentPhaseIndex = phaseIndex

  getCurrentPhaseIndex: () => return @currentPhaseIndex

  createAndSetLanguageStacks: (programLanguageStacks, allLanguageStacks) =>
    stackInput = $("#language-stack-input")
    if allLanguageStacks.length
      languageStackSelect = $("<select></select>").addClass("options-dropdown")
      languageStackSelect.attr("id", "language-stack")
      languageStackSelect.attr("multiple", "multiple")
      languageStackSelect.change ->
        if languageStackSelect.val()
          stackInput.val(languageStackSelect.val().join(", "))
        else
          stackInput.val("")
      for languageStack in allLanguageStacks
        languageStackOption = $("<option></option>").addClass("language-stack-option")
        languageStackOption.attr("value", languageStack[1])
        languageStackOption.text(languageStack[1])
        if programLanguageStacks.includes(languageStack[0])
          stackInput.val(
            stackInput.val() +
            "#{if stackInput.val() == "" then "" else ", "}" +
            languageStack[1]
          )
          languageStackOption.attr("selected", "selected")
        languageStackSelect.append(languageStackOption)

      $("#language-stacks-group").append(languageStackSelect)
    @allLanguageStacks = allLanguageStacks.map((languageStack) => languageStack[1])

  setProgramDetails: (details) =>
    programDescription = details.description
    @phases = details.phases
    @createAndSetLanguageStacks(details.program_language_stacks, details.all_language_stacks)
    @programPhasePillsEdit = new ProgramEdit.PhasePills(
      @phases,
      @onPhaseRemove,
      @reorderPhases,
      @getCurrentPhaseIndex
    )
    @programPhaseDetailsEdit = new ProgramEdit.PhaseDetails(
      @phases,
      @checkPhaseAssessments,
      @closeOtherCheckboxDropdowns,
      @changeProgramDuration,
      @setCurrentPhaseIndex,
      @getCurrentPhaseIndex
    )
    $("#program-name").val(details.name)
    @changeProgramDuration()
    $("#program-description").text(details.description)
    $("#evaluation-input").text(if details.holistic_evaluation then "Yes" else "No")
    $('#evaluation-input').trigger("holisticEvaluationChange")
    $("#program-loader-modal").hide()

  checkPhaseAssessments: (phaseIndex = 0) =>
    phase = @phases[phaseIndex]
    $(".small-checkbox").each (i, checkbox) =>
      checkboxAssessmentId = parseInt(checkbox.dataset.assessment_id)
      checkbox.checked = phase and checkboxAssessmentId in phase.assessments
      @currentPhaseIndex = phaseIndex
    $(".checkpoint.checkbox-group").hide() unless phase

  activateAddNewPhase: () =>
    $(".current-phases").on("click", (event) =>
      if $(event.target).hasClass("current-phases")
        $(".type-new-phase").focus()
    )

  changeProgramDuration: () =>
    duration = 0
    @phases.forEach((phase) => duration += (phase.phase_duration || 0))
    $("#program-duration").val(duration)

  onPhaseRemove: (event) =>
    @currentPhaseIndex = 0
    button = $(event.currentTarget)
    phaseIndex = parseInt(button.attr("id").split("-")[2])
    phasePill = $("#phase-pill-#{phaseIndex}")
    phaseDetail = $("#phase-#{phaseIndex}")
    hasPhaseDecisionBridge = @phases[phaseIndex].phase_decision_bridge
    @phases.splice(phaseIndex, 1)
    if hasPhaseDecisionBridge then phaseDetail.next().remove()
    phaseDetail.remove()
    phasePill.remove()
    @programPhaseDetailsEdit.recalibratePhases()
    @programPhaseDetailsEdit.numberDecisionBridges()
    @programPhaseDetailsEdit.changeDecisionBridgesDurations()
    @changeProgramDuration()

  createPhase: (phaseName) =>
    newPhase = {
      name: phaseName,
      phase_decision_bridge: false,
      assessments: []
    }
    @phases.push(newPhase)
    newPhaseIndex = @phases.length - 1
    @programPhaseDetailsEdit.createPhaseBox(newPhaseIndex)
    @programPhasePillsEdit.createPhasePill(newPhaseIndex)
    if @phases.length is 1
      $('.current-phase-title').text(@phases[0].name)
      $("#phase-0").find(".phase-number").addClass("phase-active")
      @currentPhaseIndex = 0
    $(".checkpoint.checkbox-group").show()
    $(".mid-part").show()
    $(".third-part").show()
    $("#phases-required").removeClass("error-mode")

  activatePhaseAdd: () =>
    $(".type-new-phase").on("keyup", (event) =>
      if event.which is 13
        @createPhase(event.currentTarget.value)
        event.currentTarget.value = ""
    )

  reorderPhases: () =>
    newPhases = []
    $(".phase-pill").each((index, element) =>
      phasePill = $(element)
      phaseNameElement = phasePill.find(".name-of-phase")
      removePhaseButton = phasePill.find(".remove-phase")
      phaseIndex = parseInt(phasePill.attr("id").split("-")[2])
      newPhases.push(@phases[phaseIndex])
      phasePill.attr("id", "phase-pill-#{index}")
      phaseNameElement.attr("id", "phase-name-#{index}")
      removePhaseButton.attr("id", "remove-phase-#{index}")
    )
    @phases = newPhases
    @programPhaseDetailsEdit.resetPhases(@phases)
    @programPhasePillsEdit.resetPhases(@phases)
    @programPhaseDetailsEdit.recreatePhaseBoxes()

  compute_cadence_name: (repeatEvery, frequency) =>
    if frequency is 1
      return "Everyday" if repeatEvery is "Day"
      return "#{repeatEvery}ly"
    return "#{frequency} #{repeatEvery}s"

  compute_cadence_days: (repeatEvery, frequency) =>
    defaults = { Day: 1, Week: 5, Month: 20 }
    return frequency * defaults[repeatEvery]

  languageStackExists: (newLanguageStack) =>
    for languageStack in @allLanguageStacks
      return languageStack if newLanguageStack.toLowerCase() is languageStack.toLowerCase()

  gatherLanguageStacks: () =>
    selectedLanguageStacks = $("#language-stack").val() || []
    newLanguageStacks = $("#language-stack-input").val().split(",")
    for newLanguageStack in newLanguageStacks
      newLanguageStack = newLanguageStack.trim()
      if newLanguageStack
        languageStack = @languageStackExists(newLanguageStack)
        if languageStack
          selectedLanguageStacks.push(languageStack) unless selectedLanguageStacks.includes(languageStack)
        else
          selectedLanguageStacks.push(newLanguageStack)
    return selectedLanguageStacks

  gatherProgramDetails: () =>
    finalProgram = {
      id: parseInt(@programId),
      name: $("#program-name").val(),
      description: $("#program-description").val(),
      estimated_duration: parseInt($("#program-duration").val()),
      language_stacks: @gatherLanguageStacks()
      phases: @phases
    }
    if $('#evaluation-input').text() is "Yes"
      repeatEvery = $("#repeat-every-input").text()
      frequency = parseInt($("#frequency").val())
      finalProgram.holistic_evaluation = {
        cadence: {
          name: @compute_cadence_name(repeatEvery, frequency)
          days: @compute_cadence_days(repeatEvery, frequency)
        }
      }
    return finalProgram

  toastErrorMessage: () =>
    $(".toast").messageToast.start("Program name #{$("#program-name").val()} already exists", "error")

  afterSubmit: (response) =>
    if response.saved
      @sendAdminNotification(response.program)
        .then () -> window.location.href = "/programs"
      return
    $("#program-loader-modal").hide()
    @toastErrorMessage()


  activateProgramSubmit: () =>
    $("#submit-program").on("click", () =>
      $('#confirm-save-modal').removeClass('confirm-save-modal-open')
      $("#program-loader-modal").show()
      @submitProgramDetails(
        @programId,
        @gatherProgramDetails(),
        @afterSubmit
      )
    )