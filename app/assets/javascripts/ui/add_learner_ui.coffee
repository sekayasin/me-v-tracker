class AddLearner.UI
  constructor: ->
    @addLearnerModal = new Modal.App('#add-learner-modal', 760, 700, 400, 400)
    @confirmationModal = new Modal.App('#confirmation-add-learner-modal', 500, 500, 300, 300)
    @addLearnerErrorModal = new Modal.App('#add-learner-error-modal', 500, 500, 300, 300)
    @loaderUI = new Loader.UI()
    @addLearnerAPI = new AddLearner.API()
    @allTabs = document.getElementsByClassName('tab')
    @country = ''
    @filterParam = {}
    @errorMessage = ''
    @warning = ''
    @closeAddLearnerModal()

  resetForm: =>
    $('#addLearnerForm').trigger('reset')
    $("#select_program, #select_dlc_stack").selectmenu("refresh")
    $('.text-file-name').html('Choose file').removeClass('active-file')
    $("#new_cycle_number").val("")
    @closeAddLearnerModal()

  openAddLearnerModal: =>
    self = @
    $('#add-learner').on 'click', ->
      self.showFirstTab()
      self.addLearnerModal.open()
      $('body').css('overflow-y', 'hidden')
      $('#modal').hide()
      self.closeAddLearnerModal()

  closeAddLearnerModal: =>
    self = @
    $('.ui-widget-overlay, .close-modal').on 'click', ->
      self.addLearnerModal.close()
      self.resetModalStatus()

  openConfirmUploadModal: =>
    self = @
    $('#add-learner-modal').parent().css('display', 'none')
    $('#add-learner-modal').css('display', 'none')
    self.confirmationModal.open()

  closeConfirmUploadModal: =>
    self = @
    self.confirmationModal.close()
    $('#add-learner-modal').parent().css('display', 'block')
    $('#add-learner-modal').css('display', 'block')

  openErrorModal: =>
    self = @
    self.addLearnerErrorModal.open()
    $('#add-learner-modal').parent().css('display', 'none')
    $('#add-learner-modal').css('display', 'none')
    $('#add-learner-error-modal').css('display', 'block')

  closeErrorModal: =>
    self = @
    $('.close-error-modal').on 'click', ->
      self.addLearnerErrorModal.close()
      $('#add-learner-modal').parent().css('display', 'block')
      $('#add-learner-modal').css('display', 'block')
      $('#add-learner-error-modal').css('display', 'none')

  cancelUpload: ->
    self = @
    $('div#confirmation-add-learner-modal').find('a.btn-cancel, .btn-cancel').click (event) ->
      self.closeConfirmUploadModal()

  resetModalStatus: =>
    self = @
    $('body').css('overflow', 'auto')
    localStorage.removeItem('isCountrySelected')
    $("#leftBtn").html('<span class="ic-prev-arrow"></span>&nbsp; Back').removeClass('close-modal')
    self.resetForm()
    self.clearError()
    self.removeSelection()

  showFirstTab: =>
    @clearError()
    @resetTabState()
    $('.first-tab').show()
    $('.steps-indicator span:first').addClass('active')
    $('#leftBtn').hide()
    $('#rightBtn').html('Next&nbsp; <span class="ic-next-arrow ic-grey"></span>').prop('disabled', true)
    localStorage.removeItem('isCountrySelected')

  resetTabState: =>
    $('.tab').hide()
    $('.step').removeClass('active')

  showSecondTab: =>
    self = @
    self.resetTabState()
    $('.second-tab').show()
    $('.steps-indicator span:nth-child(2)').addClass('active')
    $('#leftBtn').addClass('show-first-tab').show()
    $('#rightBtn').removeClass('show-second-tab').addClass('post-form-request').html('Complete&nbsp; <span class="ic-next-arrow"></span>')

  completeUploadLearner: =>
    self = @
    self.loaderUI.hide()
    $('#rightBtn').removeClass('post-form-request').addClass('complete-process')

    if $('#rightBtn').hasClass('complete-process')
      self.resetTabState()
      $('.steps-indicator span:last').addClass('active')
      $('#rightBtn').removeClass('complete-process').html("View Cycle").addClass("view-cycle")
      $("#leftBtn").removeClass('show-first-tab').hide()
      $('.last-tab').show()
      return

  showCurrentCycle: =>
    $('.loader-modal').show()
    $('.all-campers-no-data').addClass('hidden')
    $('.campers-table-body > tr').addClass('hidden').remove()
    $('.loader-modal').hide()

  showPreviousTab: =>
    self = @
    $('#leftBtn').on 'click', (event) ->
      if($(this).hasClass('show-first-tab'))
        $("#new_cycle_number").val("")
        self.showFirstTab()
        self.removeSelection()
        return

      if($(this).hasClass('close-modal'))
        self.addLearnerModal.close()
        self.resetModalStatus()
        return

  selectCountry: () =>
    self = @
    $('.country').on 'click', (event) ->
      self.removeSelection()
      $("#rightBtn").prop('disabled', false).html('Next&nbsp; <span class="ic-next-arrow"></span>')
      div = document.createElement('div')
      div.className = 'oval-4'
      div.innerHTML = '<i class="icon material-icons">check</i>'
      selectedCountry = document.getElementById(event.target.id)
      @country = event.target.id
      self.addLearnerAPI.getCountryCities(@country).then((cities) =>
        self.populateCitiesDropdown('#select_city', cities)
      )
      $("#country").val(@country)
      selectedCountry.appendChild(div)
      selectedCountry.className += ' selected-country'
      localStorage.setItem('isCountrySelected', 'selected')
      $('#rightBtn').addClass('show-second-tab')
      self.selectCityChanged()

  removeSelection: () =>
    $('.selected-country').removeClass('selected-country')
    $("div.oval-4").remove()
    $('#rightBtn').removeClass('show-second-tab')
    return

  updateUploadedFileName: ->
    $('#upload-learners-file').on 'change', =>
      file = $('#upload-learners-file')[0].files[0]
      $('.text-file-name').html(file.name).addClass('active-file')

  populateCitiesDropdown: (dropdownId, cities) =>
    $("#select-city-error").html("")
    $(dropdownId).empty()
    options = '<option value="">Select City</option>'

    for id, city of cities
      options += "<option value='#{city}'>#{city}</option>"

    $(dropdownId).append(options).selectmenu('refresh')
    return

  selectCityChanged: () ->
    $('#select_city').on 'selectmenuchange', () =>
      new_city = $('#select_city').val()
      @.addLearnerAPI.getCityLatestCycle(new_city).then((cycle) =>
        last_cycle = parseInt(cycle)
        new_cycle = last_cycle + 1
        $("#new_cycle_number").val(new_cycle)
      )

  populateDlcStackDropdown: (dropdownId, dlcStacks) ->
    $("#select-dlc-stack-error").html("")
    $(dropdownId).empty()
    options = '<option value="">Select ALC Stack</option>'

    for id, dlcStack of dlcStacks
      options += "<option value='#{dlcStack.dlc_stack_id}'>#{dlcStack.dlc_stack_name}</option>"

    $(dropdownId).append(options).selectmenu('refresh')
    return

  validateDropdowns: =>
    $("#select_program, #select_dlc_stack").on 'selectmenuselect', (event) ->
      $("#select_program_error, #select-dlc-stack-error").html('')
      return

  validateFormInput: =>
    $.validator.addMethod 'greater_than_start_date', ( ->
      endDate = $('#select_end_date').val()
      startDate = $('#select_start_date').val()

      if (startDate <= endDate)
        return true

      return false
    ), "Can not be less than start date"

    $('#addLearnerForm').validate
      focusInvalid: false
      ignore: []
      rules:
        select_program: 'required'
        select_dlc_stack: 'required'
        select_start_date: 'required'
        select_end_date:
          required: true
          greater_than_start_date: true
        select_city: 'required'
        enter_cycle_number: 'required'
        upload_learners_file:
          required: true
          extension: 'xlsx'
      messages:
        select_program: 'Please Select Program'
        select_dlc_stack: 'Please Select ALC Stack'
        select_start_date: 'Please Select Start Date'
        select_end_date:
          required: 'Please Select End Date'
        select_city: 'Please Select City / Location'
        enter_cycle_number: 'Please Enter A Cycle Number'
        upload_learners_file: 'Please Upload a .xlsx Spreadsheet file'

      errorPlacement: (error, element) ->
        if element.attr('name') == 'select_program'
          $("#select_program_error").html(error)

        else if element.attr('name') == 'select_dlc_stack'
          $("#select-dlc-stack-error").html(error)

        else if element.attr('name') == 'select_start_date'
          $("#select-start-date-error").html(error)

        else if element.attr('name') == 'select_end_date'
          $("#select-end-date-error").html(error)

        else if element.attr('name') == 'select_city'
          $("#select-city-error").html(error)

        else if element.attr('name') == 'enter_cycle_number'
          $("#enter-cycle-number-error").html(error)

        else if element.attr('name') == 'upload_learners_file'
          $("#upload-learners-file-error").html(error)

        else
          error.insertAfter(element)

  prepareError: (error) =>
    if error.headers && error.headers.length > 0
      @errorMessage = '<p>
          Please ensure the following field(s) in the header are available in the right order and are correctly spelt:
        </p>
        <ul class="list-horizontal">'

      for header in error.headers
        @errorMessage += '<li>' + header + '</li>'
      @errorMessage += '</ul>'

    else if error.rows && error.rows.length > 0
      @errorMessage = '<p>
        Please ensure the following field(s) are filled completely and correctly on '

      for row in error.rows
        @errorMessage += '</br> Row: ' + row.row[0][1].row
        @errorMessage += '</br> Error(s): <br />
        <ul>'
        for value in row.row
          @errorMessage += '<li>' + value[0] + '</li>'
        @errorMessage += '</ul>'

    else if error.email_duplicates && error.email_duplicates.length > 0
      @errorMessage = '<p>The following email address(es) is/are duplicated: </p>
      <ul class="list-horizontal">'

      for email in error.email_duplicates
        @errorMessage += '<li>' + email + '</li>'
      @errorMessage += '</ul>'

    else if error.id_duplicates && error.id_duplicates.length > 0
      @errorMessage = '<p>The following greenhouse id(s) is/are duplicated: </p>
      <ul class="list-horizontal">'

      for greenhouse_id in error.id_duplicates
         @errorMessage += '<li>' + greenhouse_id + '</li>'
      @errorMessage += '</ul>'

    else
      @errorMessage = ''

  prepareWarning: (existingUsers) =>
    @warning = 'The following learners have already been added'

    if existingUsers
      @warning = '<p> NB:
        The following learners have already been added for cycle: '
      @warning += existingUsers[0].cycle + '
        </p>
        <ul id="existing-users-list">'

      for user in existingUsers
        @warning += '<li>' + user.email + '</li>'
      @warning += '</ul>'

    else
      @warning = ''

  showError: (error) ->
    self = @
    self.prepareError(error)
    $('.error-container').html(@errorMessage)
    self.openErrorModal()
    self.loaderUI.hide()
    self.closeErrorModal()

  showWarning: (warning) ->
    self = @
    self.prepareWarning(warning)
    $('.warning-container').html(@warning)

  clearError: ->
    $('.error-container').html('')
