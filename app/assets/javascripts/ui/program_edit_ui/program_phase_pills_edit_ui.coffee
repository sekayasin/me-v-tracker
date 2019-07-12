class ProgramEdit.PhasePills
  constructor: (@phases, @onPhaseRemove, @reorderPhases, @getCurrentPhaseIndex) ->
    @createPhasePills()

  resetPhases: (phases) => @phases = phases

  onDragDrop: (event) =>
    event.preventDefault()
    event.stopPropagation()
    @placeholder.replaceWith(@dragElement)
    @reorderPhases()

  setPlaceholder: () =>
    @placeholder = $("<div></div>").addClass("placeholder")
    @placeholder.attr("draggable", true)
    @placeholder.height(46)
    @placeholder.width(@dragElement.width() + 35)
    @placeholder.on("dragenter", (event) => event.preventDefault())
    @placeholder.on("dragleave", (event) => event.preventDefault())
    @placeholder.on("dragover", (event) => event.preventDefault())
    @placeholder.on("drop", (event) => @onDragDrop(event))

  onDragStart: (event) =>
    @dragElement = $(event.currentTarget)
    @setPlaceholder()
    event.originalEvent.dataTransfer.dropEffect = "move"

  onDragOver: (event) =>
    event.preventDefault()
    currentElement = $(event.currentTarget)
    dragElementIndex = parseInt(@dragElement.attr("id").split("-")[2])
    currentElementIndex = parseInt(currentElement.attr("id").split("-")[2])
    if dragElementIndex > currentElementIndex
      currentElement.before(@placeholder)
    else if dragElementIndex < currentElementIndex
      currentElement.after(@placeholder)

  onDragEnd: (event) =>
    event.preventDefault()
    @placeholder.remove()
    @dragElement.show()
    @dragElement = null
    @placeHolder = null

  createPhasePill: (newPhaseIndex) =>
    name = @phases[newPhaseIndex].name
    phasePill = $("<div></div>").addClass("phase-pill")
    phasePill.attr("id", "phase-pill-#{newPhaseIndex}")
    phasePill.attr("draggable", true)
    nameOfPhase = $("<span></span>").addClass("name-of-phase")
    nameOfPhase.text(name)
    removePhase = $("<img />").addClass("remove-phase")
    removePhase.attr("id", "remove-phase-#{newPhaseIndex}")
    removePhase.attr("src", "/assets/close-circle.svg")
    removePhase.on("click", (event) => @onPhaseRemove(event))
    phasePill.append(nameOfPhase)
    phasePill.append(removePhase)
    phasePill.on("dragstart", (event) => @onDragStart(event))
    phasePill.on("dragover", (event) => @onDragOver(event))
    phasePill.on("dragend", (event) => @onDragEnd(event))
    $("#sortable").append(phasePill)

  createPhasePills: () =>
    @phases.forEach((phase, index) =>
      @createPhasePill(index)
    )