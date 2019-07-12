class CreateProgram.UI
  constructor: ->
    @addProgramModal = new Modal.App('#create-program-modal', 545, 545, 650, 650)
    @loaderUI = new Loader.UI()
    @showProgramPhases()
    @validateFormFields()
    @toggleAddProgramModal()
    @hideNewProgramOptions()
    @toggleDropdownArrow('.cadence-dropdown', '.program-cadence')
    @toggleDropdownArrow('.clone-program-dropdown', '.clone-program')

  toggleAddProgramModal: ->
    self = @
    $('.add-new-program').on 'click', ->
      self.openAddProgramModal()

    $('.create-new-program').on 'click', ->
      self.openAddProgramModal()

    $('.close-button, .cancel-button').on 'click', ->
      self.closeAddProgramModal()

  openAddProgramModal: ->
    self = @
    self.addProgramModal.open()
    $('body').css('overflow', 'hidden')

  closeAddProgramModal: ->
    self = @
    self.addProgramModal.close()
    self.clearFormFields()
    self.clearError()
    $('body').css('overflow', 'auto')

  toggleDropdownArrow: (dropdownClass, dropdownParentClass) =>
    $(dropdownClass).on 'selectmenuopen', (event) ->
      $(dropdownParentClass).find('.ui-icon').addClass('ui-icon-up')
    $(dropdownClass).on 'selectmenuselect', (event) ->
      $(dropdownParentClass).find('.ui-icon').removeClass('ui-icon-up')
    $(dropdownClass).on 'selectmenuclose', (event) ->
      $(dropdownParentClass).find('.ui-icon').removeClass('ui-icon-up')

  hideNewProgramOptions: =>
    $('.clone-program-dropdown').on 'selectmenuselect', (event) ->
      if $(this).val() > 0
        $('.program-phase, .holistic-evaluation-option').hide()
        $('.holistic-evaluation-checkbox > .mdl-checkbox').each (index, element) ->
          element.MaterialCheckbox.uncheck()
      else
        $('.program-phase, .holistic-evaluation-option').show()

  checkHolisticEvaluationStatus: (fetchCadences) =>
    $('input#holistic-evaluation').on 'change', ->
      if $(this).prop 'checked'
        $('.program-cadence').show()
        if $('#cadence-dropdown option').length == 1
          fetchCadences()
      else
        $('.program-cadence').hide()

  clearFormFields: =>
    $('input[name="program_name"]').val ''
    $('textarea[name="program_description"]').val ''
    $('input[name="program_phase"]').val ''
    $('.program-phases-tags').empty()
    $('.holistic-evaluation-checkbox > .mdl-checkbox').each (index, element) ->
      element.MaterialCheckbox.uncheck()
    $('.program-cadence').hide()
    $('div.clone-program, div.program-cadence').find('select').val('')
    $('.clone-program-dropdown, .cadence-dropdown').selectmenu('refresh')
  
  clearError: =>
    $('.program-error').html ''

  getProgramPhases: =>
    phases = []
    $('.mdl-chip__text').each (index, element) ->
      phases.push element.textContent
    return phases

  submitForm: (saveProgram) =>
    self = @
    $('.save-program-button').on 'click', ->
      if $('#create-program-form').valid()
        self.loaderUI.show()
        saveProgram()
  
  showProgramPhases: =>
    self = @
    phaseNumber = 1
    $('input[name="program_phase"]').on 'keydown', (event) ->
      if event.keyCode == 13
        newPhase = $('input[name="program_phase"]').val().trim()
        allPhases = self.getProgramPhases()
        $('input[name="program_phase"]').val('')
        if newPhase.length >= 1 && !allPhases.includes("#{newPhase}")
          $('.program-phases-tags').append """
            <span class="mdl-chip mdl-chip--deletable" id="phase-#{phaseNumber}">
              <span class="mdl-chip__text">#{newPhase}</span>
              <button type="button" class="mdl-chip__action"><i class="material-icons remove-chip">close</i></button>
            </span>
            """

          $("#phase-#{phaseNumber} > button").on 'click', ->
            $(this).parent().remove()
          phaseNumber += 1

  validateFormFields: =>
    self = @
    $.validator.addMethod 'require-phase', ( ->
      isClone = $('.clone-program-dropdown').val() > 0
      hasPhase = self.getProgramPhases().length > 0

      if (isClone)
        return true
      if (!isClone && hasPhase)
        return true

      return false

    ), $.validator.messages.required

    $('#create-program-form').validate
      focusInvalid: false
      ignore: []
      rules:
        program_name: 'required'
        program_description: 'required'
        program_phase: 'require-phase'
        select_cadence:
          required: -> $('input#holistic-evaluation').prop 'checked'

      messages:
        program_name: 'Program Name is required'
        program_description: 'Program Description is required'
        program_phase: 'Program Phase is required'
        select_cadence: 'Please select a cadence'

      errorPlacement: (error, element) ->
        if element.attr('name') == 'program_name'
          $('#program_name-error').html error
        if element.attr('name') == 'program_description'
          $('#program_description-error').html error
        if element.attr('name') == 'program_phase'
          $('#program_phase-error').html error
        if element.attr('name') == 'select_cadence'
          $('#select_cadence-error').html error

    $('.cadence-dropdown').on 'selectmenuselect', (event) ->
      $('#select_cadence-error').html ''

  getProgramParameters: =>
    self = @
    programParams = {
      name: $('input[name="program_name"]').val()
      description: $('textarea[name="program_description"]').val()
    }

    if $('#clone-program-dropdown').val() > 0
      programParams.program_id = $('#clone-program-dropdown').val()
    else
      programParams.phases = self.getProgramPhases()
      programParams.holistic_evaluation = $('input#holistic-evaluation').prop 'checked'
      programParams.cadence_id = $('.program-cadence > select').val()

    return programParams

  populateCadenceDropdown: (cadences) =>
    for key, cadence of cadences
      $('.cadence-dropdown').append """
        <option value="#{cadence.id}">#{cadence.name}</option>
      """

  displayToastMessage: (message, status) =>
    $(".toast").messageToast.start(message, status)
