class AddFacilitator.UI
  constructor: ->
    @addFacilitatorModal = new Modal.App('#add-facilitator-modal', 760, 700, 400, 400)
    @loaderUI = new Loader.UI()
    @addFacilitatorAPI = new AddFacilitator.API()
    @allTabs = document.getElementsByClassName('tab')
    @country = ''
    @filterParam = {}
    @errorMessage = ''
    @warning = ''
    @learners =  []
    @filteredLearners = []
    @learner_programs = []
    @selectedLearnersIds = []
    @cities = []
    @emailRegEx = new RegExp(/^((?!\.)[a-z0-9._%+-]+(?!\.)\w)@andela\.com$/i)

  resetForm: =>
    $("#add_facilitator_form")[0].reset()
    learners_tags = $('#learner-name-tags')
    learners_tags.html('')
    $('#select_fac_city_error').html('')
    $('#learner_name_error').html('')
    $('#input_fac_email_error').html('')
    $('#select_week_error').html('')
    $('#right_btn_facilitator').removeClass('close-fac-modal')
    learners_tags.css('margin-bottom', '0px')
    @selectedLearnersIds = []
    @filteredLearners = []
    @learners = []
    $('.ui-selectmenu-text').html('Select Week')
    learner_name = $('input[name="learner_name"]')
    learner_name.attr('placeholder', 'First select a city...')
    learner_name.attr('disabled', true)

  showNextTab: =>
    self = @
    $('#right_btn_facilitator').on 'click', (event) ->
      if $(this).hasClass('show-second-tab')
        self.showSecondTab()
        return

      if $(this).hasClass('post-form-request')
        self.submitForm()
        return

  submitForm: =>
    self = @
    if @selectedLearnersIds.length == 0
      $('#add_facilitator_form').valid()
      $('#learner_name_error').html(
        """
        <label id="learner_name-error" class="error" for="learner_name">
          Select at least one learner.
        </label>
        """
      )
      return

    if $('#add_facilitator_form').valid()
      self.loaderUI.show()
      self.addFacilitatorAPI.updateLearnerLfa({
        selectedLearners: @selectedLearnersIds,
        lfaEmail: $('input[name="input_fac_email"]').val(),
        week: $('select[name="select_week"]').val(),
      }).then ((message) ->
        self.loaderUI.hide()
        self.completeAddFacilitator()
      )
    else
      return

  completeAddFacilitator: =>
    self = @
    self.loaderUI.hide()
    $('#right_btn_facilitator').removeClass('post-form-request')
      .addClass('complete-process')

    if $('#right_btn_facilitator').hasClass('complete-process')
      self.resetTabState()
      $('#steps-indicator span:last').addClass('active')
      $('#right_btn_facilitator')
        .html('CLOSE')
        .addClass('close-fac-modal')
      $('.close-fac-modal').on 'click', ->
        if $(this).hasClass('close-fac-modal')
          self.resetModalStatus()
          self.addFacilitatorModal.close()
      $("#left_btn_facilitator").removeClass('show-first-tab').hide()
      $('.last-tab').show()
      return

  getLearnerTags: =>
    learners = []
    $('#learner-name-text').each (index, element) ->
      learners.push element.textContent
    return learners

  openAddFacilitatorModal: =>
    self = @
    $('#add-lfa').on 'click', ->
      $('#right_btn_facilitator').removeClass('close-fac-modal')
      self.showFirstTab()
      self.addFacilitatorModal.open()
      $('body').css('overflow-y', 'hidden')
      $('#modal').hide()
      self.closeAddFacilitatorModal()

  closeAddFacilitatorModal: =>
    self = @
    $('.ui-widget-overlay, .close-modal').on 'click', ->
      self.addFacilitatorModal.close()
      self.resetModalStatus()

  resetModalStatus: =>
    self = @
    $('body').css('overflow', 'auto')
    localStorage.removeItem('isCountrySelected')
    $("#left_btn_facilitator").html('<span class="ic-prev-arrow"></span>&nbsp; Back').removeClass('close-modal')
    self.resetForm()
    self.clearError()
    self.removeSelection()

  showFirstTab: =>
    self = @
    self.resetTabState()
    $('.first-tab').show()
    $('#steps-indicator span:first').addClass('active')
    $('#left_btn_facilitator').hide()
    $('#right_btn_facilitator').html('Next&nbsp; <span class="ic-next-arrow ic-grey"></span>').prop('disabled', true)
    localStorage.removeItem('isCountrySelected')

  resetTabState: =>
    $('.tab').hide()
    $('.step').removeClass('active')

  showSecondTab: =>
    self = @
    self.resetTabState()
    $('.second-tab').show()
    $('#steps-indicator span:nth-child(2)').addClass('active')
    $('#left_btn_facilitator').addClass('show-first-tab').show()
    $('#right_btn_facilitator').removeClass('show-second-tab')
    .addClass('post-form-request')
    .html('Complete&nbsp; <span class="ic-next-arrow"></span>')

  showPreviousTab: =>
    self = @
    $('#left_btn_facilitator').on 'click', (event) ->
      if($(this).hasClass('show-first-tab'))
        self.showFirstTab()
        self.removeSelection()
        self.resetModalStatus()
        return

      if($(this).hasClass('close-modal'))
        self.addFacilitatorModal.close()
        self.resetModalStatus()
        return

  selectCountry: () =>
    self = @
    $('.facilitator-country').on 'click', (event) ->
      self.removeSelection()
      $("#right_btn_facilitator").prop('disabled', false)
      .html('Next&nbsp; <span class="ic-next-arrow"></span>')
      div = document.createElement('div')
      div.className = 'oval-4'
      div.innerHTML = '<i class="icon material-icons">check</i>'
      selectedCountry = document.getElementById(event.target.id)
      @country = event.target.id.substring(12)
      self.addFacilitatorAPI.getCities(@country).then((cities) =>
        self.country = @country
        self.cities = cities
        self.populateCitiesDropdown('#select_fac_city', cities)
      )
      $("#facilitator-country").val(@country)
      selectedCountry.appendChild(div)
      selectedCountry.className += ' selected-country'
      localStorage.setItem('isCountrySelected', 'selected')
      $('#right_btn_facilitator').addClass('show-second-tab')

  removeSelection: () =>
    $('.selected-country').removeClass('selected-country')
    $("div.oval-4").remove()
    $('#right_btn_facilitator').removeClass('show-second-tab')

  initializeSelectWeek: () =>
    self = @
    $(document).on 'click', '.ui-menu-item', ->
      item = $(this).text()
      self.selectWeek()

  selectWeek: () =>
    self = @
    week = $('select[name="select_week"]').val()
    @selected_city = $('select[name="select_fac_city"]').val()
    self.initializeDropdown()
    learner_name = $('input[name="learner_name"]')
    if week && @selected_city
      learner_name
        .attr('placeholder', 'Start typing learner name or email...')
      learner_name.attr('disabled', false)
      $('#select_week_error').html('')
    else if week && !@selected_city
      learner_name
        .attr('placeholder', 'First select a city...')
      learner_name.attr('disabled', false)
      $('#select_week_error').html('')
    else
      learner_name
        .attr('placeholder', 'Select a week...')
      learner_name.attr('disabled', true)
      return
    self.filteredLearners = self.learners.filter (learner) ->
      if week == 'Week 2'
        learner_prorgram = self.learner_programs.find((program) ->
          program.decision_one == 'Advanced' &&
          program.camper_id == learner.camper_id
        )
        if learner_prorgram
          learner['label'] = "#{learner.first_name}
          #{learner.last_name} #{learner.email}"
          learner['value'] = learner.camper_id
          return true
        else
          return false
      learner['label'] = "#{learner.first_name}
      #{learner.last_name} #{learner.email}"
      learner['value'] = learner.camper_id
      return true
    self.initializeLearnerDropdown()

  populateCitiesDropdown: (dropdownId, cities) =>
    $("#select-fac-city-error").html("")
    $(dropdownId).empty()
    options = '<option value="">Select City</option>'

    for id, city of cities
      options += "<option value='#{city}'>#{city}</option>"
    $(dropdownId).append(options).selectmenu('refresh')
    return

  initializeDropdown: () =>
    self = @
    learner_name = $('input[name="learner_name"]')
    @selected_city = $('select[name="select_fac_city"]').val()
    if @country.trim().length > 0 and @selected_city
      self.addFacilitatorAPI
        .getLearners(@country, @selected_city).then((data) ->
          self.learners = data.learners
          self.learner_programs = data.learner_programs
        ) .catch((error) ->
            learner_name.attr('disabled', true)
            learner_name
              .attr('placeholder', 'No bootcamp here...')
        )

  getUnselectedLearners: =>
    self = @
    return self.filteredLearners.filter((learner) ->
      return !self.selectedLearnersIds.find((id) ->
        return id == learner.camper_id
      )
    )

  initializeLearnerDropdown: =>
    self = @
    unselectedLearners = self.getUnselectedLearners()
    learner_name = $('input[name="learner_name"]')
    learner_name.autocomplete(
      source: unselectedLearners
      limit: 5
      select: (event, ui) ->
        learner_name.val('')
        $('#learner_name_error').html('')
        event.preventDefault()
        foundLearnerId = self.selectedLearnersIds.find((id) ->
          id == ui.item.camper_id
        )
        if foundLearnerId
          return
        full_name = "#{ui.item.first_name} #{ui.item.last_name}"
        $('#learner-name-tags').css('margin-bottom', '15px')
        $('#learner-name-tags').append """
          <span class="mdl-chip mdl-chip--deletable">
            <span id="learner-name-text" class="mdl-chip__text">#{full_name}</span>
            <button type="button" id="learner-#{ui.item.camper_id}" class="mdl-chip__action"><i class="material-icons remove-chip">close</i></button>
          </span>
          """
        self.selectedLearnersIds.push ui.item.camper_id
        self.initializeLearnerDropdown()
        $("#learner-#{ui.item.camper_id}").on 'click', ->
          $(this).parent().remove()
          self.selectedLearnersIds = self.selectedLearnersIds.filter((id) ->
            id != ui.item.camper_id
          )
          self.initializeLearnerDropdown()
          if self.getLearnerTags().length == 0
            $('learner-name-tags').css('margin-bottom', '0px')

    ).data('ui-autocomplete')._renderItem = (ul, learner) ->
      full_name = "#{learner.first_name} #{learner.last_name}"
      $('<li>').data('ui-autocomplete-item', learner)
        .append full_name
        .appendTo ul
    
    learner_name.attr('autocomplete', 'random')

  validateFormInput: () =>
    self = @
    $.validator.addMethod 'validate_lfa_email', ( ->
      lfaEmail = $('.enter-lfa-email').val()
      return self.emailRegEx.test(lfaEmail)
    ), "Please provide a valid Andela email."

    $('#add_facilitator_form').validate
      focusInvalid: false
      ignore: []
      rules:
        input_fac_email:
          required: true
          validate_lfa_email: true
        select_fac_city:
          required: true
        select_week: 'required'
      messages:
        input_fac_email:
          required: 'Please provide facilitator\'s email.'
          validate_lfa_email: 'Please provide a valid Andela email.'
        select_week: 'Please select a bootcamp week.'
        select_fac_city:
          required: 'The facilitator\'s city is required.'
      errorPlacement: (error, element) ->
        if element.attr('name') == 'input_fac_email'
          $("#input_fac_email_error").html(error)
        else if element.attr('name') == 'select_fac_city'
          $("#select_fac_city_error").html(error)
        else if element.attr('name') == 'select_week'
          $("#select_week_error").html(error)
        else
          error.insertAfter(element)

  clearError: ->
    $('.error-container').html('')
