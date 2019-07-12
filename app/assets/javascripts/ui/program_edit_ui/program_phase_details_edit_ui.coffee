class ProgramEdit.PhaseDetails
  constructor: (
    @phases,
    @checkPhaseAssessments,
    @closeOtherCheckboxDropdowns,
    @changeProgramDuration,
    @setCurrentPhaseIndex,
    @getCurrentPhaseIndex
  ) ->
    @recreatePhaseBoxes()

  resetPhases: (phases) => @phases = phases

  computeDecisionDuration: (phaseIndex) =>
    duration = 0
    @phases.forEach((phase, index) =>
      if index <= phaseIndex then duration += (phase.phase_duration || 0)
    )
    return duration

  changeDecisionBridgeDuration: (decisionBrigde) =>
    phaseElement = decisionBrigde.prev()
    phaseIndex = parseInt(phaseElement.attr("id").split("-")[1])
    decisionDuration = @computeDecisionDuration(phaseIndex)
    decisionBrigde.find(".phase-details").find(".phase-form-group").text("AFTER #{ decisionDuration } DAY#{ if decisionDuration > 1 then 'S' else '' }")

  changeDecisionBridgesDurations: () =>
    $(".path").each((i, element) => @changeDecisionBridgeDuration($(element)))

  createPhaseDecisionBridge: (phaseElement) =>
    phaseIndex = parseInt(phaseElement.attr("id").split("-")[1])
    decisionDuration = @computeDecisionDuration(phaseIndex)
    phase = @phases[phaseIndex]
    phaseDecisionBridgeElement = $("<div></div>").addClass("path")
    phaseDecisionElement = $("<div><h5>D</h5></div>").addClass("phase-decision")
    phaseDetailsElement = $("<div></div>").addClass("phase-details")
    phaseNameElement = $("<span>Decision</span>").addClass("phase-name")
    phaseDecisionBridgeElement.append(phaseDecisionElement)
    phaseFormGroupElement = $("<div></div>").addClass("phase-form-group")
    phaseDetailsElement.append(phaseNameElement)
    phaseDetailsElement.append(phaseFormGroupElement)
    phaseFormGroupElement.text("AFTER #{ decisionDuration } DAY#{ if decisionDuration > 1 then 'S' else '' }")
    phaseDecisionBridgeElement.append(phaseDetailsElement)
    phaseElement.after(phaseDecisionBridgeElement)

  removePhaseDecisionBridge: (phaseElement) =>
    phaseElement.next().remove()

  changePhaseDuration: (event) =>
    duration = parseInt(event.currentTarget.value)
    phaseIndex = parseInt($(event.currentTarget).closest(".phase").attr("id").split("-")[1])
    if duration then @phases[phaseIndex].phase_duration = duration else @phases[phaseIndex].phase_duration = null

  numberDecisionBridges: () =>
    decisionBridges = $(".path")
    decisionBridges.each (i, decisionBridge) =>
      $(decisionBridge).find(".phase-details").find(".phase-name").text("Decision #{ i + 1 }")

  numberDecisionBridges: () =>
    decisionBridges = $(".path")
    decisionBridges.each (i, decisionBridge) =>
      $(decisionBridge).find(".phase-details").find(".phase-name").text("Decision #{ i + 1 }")

  onDecisionBridgeChange: (event) =>
    event.stopPropagation()
    checked = event.currentTarget.checked
    phaseElement = $(event.currentTarget.closest('.phase'))
    phaseIndex = parseInt(phaseElement.attr("id").split("-")[1])
    @phases[phaseIndex].phase_decision_bridge = checked
    if checked
      @createPhaseDecisionBridge(phaseElement)
    else
      @removePhaseDecisionBridge(phaseElement)
    @numberDecisionBridges()

  activateDecisionBridgeChange: () =>
    checkboxes = $('.medium-checkbox')
    checkboxes.on('click', (event) => @onDecisionBridgeChange(event))

  changePhase: (event) =>
    selectedPhase = $(event.currentTarget)
    phaseIndex = parseInt(selectedPhase.parent().attr("id").split("-")[1])
    $('.current-phase-title').text(@phases[phaseIndex].name)
    $(".phase-number").removeClass('phase-active')
    selectedPhase.addClass('phase-active')
    @setCurrentPhaseIndex(phaseIndex)
    @closeOtherCheckboxDropdowns()
    @checkPhaseAssessments(phaseIndex)

  recalibratePhases: () =>
    $('.phase-number').removeClass('phase-active')
    phasePills = $(".phase-pill")
    namesOfPhases = $(".name-of-phase")
    removePhaseButtons = $(".remove-phase")
    phases = $(".phase")
    phasePills.each (index, element) => $(element).attr("id", "phase-pill-#{index}")
    namesOfPhases.each (index, element) => $(element).attr("id", "phase-name-#{index}")
    removePhaseButtons.each (index, element) => $(element).attr("id", "remove-phase-#{index}")
    phases.each (index, element) =>
      phase = $(element)
      phaseNumber = phase.find(".phase-number")
      phase.attr("id", "phase-#{index}")
      phaseNumber.find("h5").text(index + 1)
      if index is 0
        phaseNumber.addClass('phase-active')
        $('.current-phase-title').text(@phases[index].name)
    @closeOtherCheckboxDropdowns()
    unless @phases.length
      $(".mid-part").hide()
      $(".third-part").hide()
      $("#phases-required").addClass("error-mode")
    @checkPhaseAssessments()

  createPhaseBox: (newPhaseIndex) =>
    phase = @phases[newPhaseIndex]
    phaseBox = $("<div></div>").addClass("phase")
    phaseBox.attr("id", "phase-#{newPhaseIndex}")
    phaseNumber = $("<div></div>").addClass("phase-number #{if newPhaseIndex is 0 then "phase-active" else ""}")
    phaseNumber.append($("<h5>#{newPhaseIndex + 1}</h5>"))
    phaseNumber.on("click", (event) => @changePhase(event))
    phaseBox.append(phaseNumber)
    phaseDetails = $("<div></div>").addClass("phase-details")
    phaseName = $("<span></span>").addClass("phase-name").text(phase.name)
    phaseDetails.append(phaseName)
    phaseFormGroup = $("<div></div>").addClass("phase-form-group")
    phaseFormGroup.append("<label>Duration (Days):</label>")
    phaseDuration = $("<input></<input>").addClass("medium-input phase-duration")
    phaseDuration.on("keyup click", (event) =>
      @changePhaseDuration(event)
      @changeProgramDuration()
      @changeDecisionBridgesDurations()
    )
    phaseDuration.attr("type", "number")
    phaseDuration.attr("min", "0")
    phaseDuration.val(phase.phase_duration)
    phaseFormGroup.append(phaseDuration)
    phaseDetails.append(phaseFormGroup)
    phaseCheckboxGroup = $("<div></div>").addClass("checkbox-group")
    phaseDecision = $("<input></<input>").addClass("medium-checkbox")
    phaseDecision.attr("type", "checkbox")
    phaseDecision.attr('checked', phase.phase_decision_bridge)
    phaseDecision.on("click", (event) => @onDecisionBridgeChange(event))
    phaseCheckboxGroup.append(phaseDecision)
    phaseCheckboxGroup.on("click", () => phaseDecision.trigger("click"))
    phaseCheckboxGroup.append("Include Decision Bridge")
    phaseDetails.append(phaseCheckboxGroup)
    phaseBox.append(phaseDetails)
    $("#phase-boxes").append(phaseBox)

  recreatePhaseBoxes: () =>
    @setCurrentPhaseIndex(0)
    $("#phase-boxes").empty()
    @phases.forEach((phase, index) =>
      @createPhaseBox(index)
      if phase.phase_decision_bridge then @createPhaseDecisionBridge($("#phase-#{index}"))
      if index is 0 then $('.current-phase-title').text(@phases[index].name)
    )
    @numberDecisionBridges()
    @checkPhaseAssessments()
    @closeOtherCheckboxDropdowns()
