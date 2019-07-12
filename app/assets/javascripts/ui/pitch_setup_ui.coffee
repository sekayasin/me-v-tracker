class Pitch.PitchSetup.UI
  constructor: (@api) ->
    @allTabs = document.getElementsByClassName('pitch-tab')
    @pitch_id = ''
    @pitch_date = ''
    @pitchId = null
    @pitch_lfa_email = []
    @pitch_cycle_selected = ''
    @cycle_center_id = ''
    @cycle_number = ''
    @center_name = ''
    @program = ''
    @program_id = ''
    @pitch_campers_id = []
    @details = {}
    @pitches = []
    @learnersContentPerPage = 10
    @summaryContentPerPage = 10
    @contentPerPage = 14
    @pagination = new PaginationControl.UI()
    @deleteConfirmationModal = new Modal.App('#pitch-delete-confirmation-modal', 500, 500, 255, 255)
    @learnerPagination = new PaginationControl.UI()
    @summaryPagination = new PaginationControl.UI()
    @updates = {
      program: false,
      cycle_center: false,
      added_panelists: [],
      removed_panelists: [],
      demo_date: false,
    }
    @learnerModal = new Pitch.LearnerRatingModal.App()

  initialize: ->
    @showProgramSelect()
    @showCycleSelect()
    @handleProgramDropdownClick()
    @handleCycleDropdownClick()
    @showFirstTab()
    @showNextTab()
    @showPreviousTab()
    @addPitchPanelist()
    @showDatePicker()
    @getAllPitches()
    @fetchPitchLearners() if pageUrl[2] && typeof Number(pageUrl[2]) == 'number'
    @registerSubmitButton()
    @fetchPitchLearnerAverage()

  update: (pitch_id) ->
    @editPitch(pitch_id)
    @registerUpdateButton()

  showDatePicker: ->
    self = @
    $('#select-demo-date').datepicker({
      showOtherMonths: true,
      selectOtherMonths: false,
      minDate: new Date()
      beforeShowDay: $.datepicker.noWeekends,

      onSelect: (date) ->
        date_selected = date.split('/')
        date_selected_now = "#{date_selected[2]}-#{date_selected[0]}-#{date_selected[1]}"
        self.pitch_date = date_selected_now
        self.updates.demo_date = true if pageUrl[3] is 'edit'
        return
    }).find('a.ui-state-highlight').removeClass('ui-state-highlight ui-state-active')


  showFirstTab: ->
    @resetTabState()
    $('.pitch-tab-1').show()
    word = if pageUrl[3] is 'edit' then 'Update' else 'Create a New'
    $('#tab-btn-back-text').text("#{word} Pitch")
    $('#tab-btn-back').addClass('first-tab')

  resetTabState: ->
    $('.pitch-tab').hide()

  showThirdTab: ->
    @resetTabState()
    $('.pitch-tab-3').show()
    $('#tab-btn-back-text').text('Invite Panellists')
    $('#tab-btn-back').removeClass('first-tab').addClass('third-tab')

  showForthTab: ->
    self = @
    self.resetTabState()
    self.showDatePicker()
    $('.pitch-tab-4').show()
    $('#tab-btn-back-text').text('Schedule Demo Day')
    $('#tab-btn-back').removeClass('third-tab').addClass('forth-tab')
    $('a.ui-state-default').removeClass('.ui-state-highlight')
    $('#next-btn').hide()
    elem = if pageUrl[3] is 'edit' then '#update-btn' else '#submit-btn'
    $("#{elem}").show()

  registerSubmitButton: ->
    self = @
    $('.submit-next').click ->
      self.setPitchDetails()
      if $('.submit-next.next-btn').text() == 'Submit' && self.pitch_date
         $('.saving').show()
         $('#submit-btn').hide()
         self.api.createPitch(self.details, self.flashErrorMessage)
          .then((data) -> (
            if data.message != "Pitch successfully created"
              self.flashErrorMessage(data.message)
              $('.saving').hide()
              $('#submit-btn').show()
            else
              self.flashSuccessMessage(data.message)
              window.location.href = "#{location.protocol}//#{location.host}/#{pageUrl[1]}"
          ))
      else
        self.flashErrorMessage("Please select the pitch date")

  registerUpdateButton: ->
    self = @
    $('.update-next').click ->
      self.setPitchDetails()
      if $('.update-next.next-btn').text() == 'Update' && self.pitch_date
        $('.updating').show()
        $('#update-btn').hide()
        self.api.updatePitch(self.pitch_id, self.details, self.flashErrorMessage)
          .then((data) -> (
            if data.message == "An error occurred"
              self.flashErrorMessage(data.message)
              $('.updating').hide()
              $('#update-btn').show()
            else
              self.flashSuccessMessage(data.message)
              window.location.href = "#{location.protocol}//#{location.host}/#{pageUrl[1]}/#{pageUrl[2]}"
          ))
      else
        self.flashErrorMessage("Please select the pitch date")

  setPitchDetails: () ->
    @details = {
      pitch_id: @pitch_id
      camper_id: @pitch_campers_id
      lfa_email: @pitch_lfa_email
      cycle_center_id: @cycle_center_id
      cycle_number: @cycle_number
      center_name: @center_name
      demo_date: @pitch_date
      program_id: @program_id
      updates: @updates
    }

  showPreviousTab: ->
    self = @
    $('#tab-btn-back').on 'click', (event) ->
      if ($(this).hasClass('forth-tab')) && ((!$('.saving').is(':hidden')) || (!$('.updating').is(':hidden')))
        return
      if ($(this).hasClass('forth-tab'))
        self.showThirdTab()
        $(this).removeClass('forth-tab')
        $('#next-btn').show()
        $('#submit-btn, #update-btn, .saving, .updating').hide()
        return
      if ($(this).hasClass('third-tab'))
        self.showFirstTab()
        $(this).removeClass('third-tab')
        return
      if ($(this).hasClass('first-tab'))
        window.location.href = "#{location.protocol}//#{location.host}/#{pageUrl[1]}"

  showNextTab: ->
    self = @
    $('#next-btn').on 'click', (event) ->
      if ($('#tab-btn-back').hasClass('first-tab'))
        if (!self.program)
          self.flashErrorMessage("Please select a program")
        else if (!self.cycle_center_id)
          self.flashErrorMessage("Please select a cycle")
        else if (!self.pitch_campers_id.length)
          self.flashErrorMessage("No advanced bootcampers in selected cycle")
        else
          self.showThirdTab()
          return

      if ($('#tab-btn-back').hasClass('third-tab'))
        if (self.pitch_lfa_email.length == 0)
          self.flashErrorMessage("Please enter a panelist email")
        else
          self.showForthTab()
          return

      if ($('#tab-btn-back').hasClass('forth-tab'))
        return

  showProgramSelect: ->
    $('html').on 'click', (e) ->
      if (not $(e.target).is('#program-select-option'))
        $('#program-options-wrapper').hide()

    $('#program-select-option').on 'click', (e) ->
      e.stopPropagation()
      $('.pitch-options-wrapper').hide()
      if $('#program-options-wrapper').css('display') is 'block'
        $('#program-options-wrapper').hide()
      else
        $('#program-options-wrapper').show()

  showCycleSelect: ->
    self = @
    $('html').on 'click', (e) ->
      if (not $(e.target).is('#cycle-select-option'))
        $('#cycle-options-wrapper').hide()

    $('#cycle-select-option').on 'click', (e) ->
      e.stopPropagation()
      $('.pitch-options-wrapper').hide()
      if $('#cycle-options-wrapper').css('display') is 'block'
        $('#cycle-options-wrapper').hide()
      else
        $('#cycle-options-wrapper').show()
        self.populatePitchCycle()
        self.handleCycleDropdownClick()

  getAllCamperInCenter: (center) ->
    self = @
    @api.getAllCampersInCenter(center, self.flashErrorMessage)
      .then((res) -> (
        self.pitch_campers_id = res.data
        ))

  getProgramCycleCenter: (program_id) ->
    self = @
    @api.getProgramCycleCenter(program_id, self.flashErrorMessage)
      .then((res) -> (
          self.pitch_cycle = res.centers
        ))

  handleProgramDropdownClick: ->
    self = @
    $('.pitch-select-program').on 'click', () ->
      self.program = $.trim($(this).text())
      self.program_id = $(this).closest("div").find(".program-id").attr('value')
      self.getProgramCycleCenter(self.program_id)
      $('#selected').text($(this).text())
      $('#pitch_cycle-value').text('Choose Here')
      $('#program-options-wrapper').hide()

  handleCycleDropdownClick: ->
    self = @
    $('.pitch-select-cycle').on 'click', () ->
      self.pitch_cycle_selected = $.trim($(this).text())
      $('#program-options-wrapper').hide()
      self.cycle_center_id = $(this).closest("div").find(".cycle-centerid").attr('value')
      self.updates.cycle_center = true if pageUrl[3] is 'edit'
      self.getAllCamperInCenter(self.cycle_center_id)
      name = self.pitch_cycle_selected.split(' ')
      $('#pitch_cycle-value').text(self.pitch_cycle_selected)
      $('.pitch-cohort').text("#{name[0] ?= Lagos } Cycle #{name[2] ?= 44}")
      $('#cycle-options-wrapper').hide()

  populatePitchCycle: ->
    self = @
    options = ''
    text = """
        <div class="pitch-option pitch-select-cycle">
          <p class="with-icon">No active cycle for the selected program</p>
        </div>
    """
    self.pitch_cycle.map (option) ->
      options += """
        <div class="pitch-option pitch-select-cycle">
          <p class="with-icon">#{option.name} -- #{option.cycle}</p>
          <input type='hidden' value='#{option.cycle_center_id}' class='cycle-centerid'/>
        </div>"""
    if self.pitch_cycle.length == 0
      $('div#pitch-options-list').html(text)
    else
      $('div#pitch-options-list').html(options)

  addPitchPanelist: ->
    self = @
    $('.invite-panelist').on 'keypress', (e) ->
      if (e.which == 13 )
        e.preventDefault()
        self.acceptPanelistInputHelper(self.pitch_lfa_email)
        return

    $('.add-invitee-icon').on 'click',  ->
      self.acceptPanelistInputHelper(self.pitch_lfa_email)

  acceptPanelistInputHelper: (pitch_lfa_email) ->
    email_pattern = /^[a-z]{2,}\.[a-z]{2,}@andela\.com$/
    panelist_email = $.trim($('.invite-panelist').val())

    return @flashErrorMessage("Email must be an Andela Email") unless panelist_email.match email_pattern
    return @flashErrorMessage("Email is already in the list") if @pitch_lfa_email.indexOf(panelist_email) != -1

    @pitch_lfa_email.unshift panelist_email if panelist_email != ''
    @updates.added_panelists.push panelist_email if pageUrl[3] is 'edit'
    $('.invite-panelist').val('')
    @displayPanelistEmail(@pitch_lfa_email)

  displayPanelistEmail: (pitch_lfa_email) ->
    self = @
    options = ''
    pitch_lfa_email.map (email) ->
      name = email.split(".")
      first = name[0].slice(0,1)
      second = name[1].slice(0,1)
      options += """
      <div class="invitee-list-item">
      <div class="invitee-detail">
        <span class="invitee-initials">
        #{first}#{second}
        </span>
        <span class="invitee-email">
          #{email}
        </span>
      </div>
      <span class="close-btn lfa-delete"></span>
      </div>
      """
    $('div.list-lfa-email').html(options)
    self.deletePanelistEmail(pitch_lfa_email)
    options = ''

  deletePanelistEmail: (pitch_lfa_email) ->
    self = @
    $(".lfa-delete").click (e) ->
      index = $('.invitee-list-item').index(e.target.closest('.invitee-list-item'))
      e.target.closest('.invitee-list-item').remove()
      deleted = pitch_lfa_email.splice(index, 1)
      self.updates.removed_panelists = self.updates.removed_panelists.concat deleted if pageUrl[3] is 'edit'

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')

  getAllPitches: =>
    self = @
    if pageUrl[1] == 'pitch' && pageUrl.length == 2
      @api.getPitchData(self.contentPerPage, self.pagination.page)
        .then((data) -> (
          return unless data.admin || data.panelist
          self.admin = data.admin
          self.panelist = data.panelist
          pitchesData = data.paginated_data
          self.pitchesCount = data.data_count
          self.pagination.initialize(
            self.pitchesCount, self.api.getPitchData,
            self.populatePitches, self.contentPerPage,
            {}, ".pagination-control.pitches-pagination"
          )
          self.populatePitches(pitchesData)
        ))

  editPitch: (pitch_id) ->
    self = @
    @api.editPitch(pitch_id)
      .then((data) -> (
        return unless data
        self.populateFields(data)
      ))

  populatePitches: (pitchesData) =>
    self = @
    $("#pitches-count").html self.pitchesCount
    $(".pitches-grid").html("")
    return unless self.admin || self.panelist
    if self.admin
      $(".pitches-grid").html("").append(
        "<div class='add-new-pitch-card' id='new-pitch-btn'>
          <div class='add-icon'></div>
            <p>Add a new Pitch</p>
        </div>"
      )

    $(".add-new-pitch-card").click ->
      window.location.href = '/pitch/setup'

    if self.pitchesCount == 0
      $(".dashboard-main-section").html("").append(
        "<div class='empty-pitch'>
        <div class='empty-image'></div>
        <p>No Pitches have been created</p>
        <a href='/pitch/setup' class='new-pitch-btn' id='new-pitch-btn'> Add a new Pitch</a>
        </div>"
      )

    pitchesData.forEach((pitch) ->
      self.populatePitchesCard(pitch)
    )
    self.openDeleteConfirmationModal()

  populatePitchesCard: (pitch) ->
    self = @

    if self.admin
      pitchDetails = """
        <div class="pitch-card">
          <div class="body" onclick='window.location = "pitch/#{pitch.pitch_id}"'>
            <div class="title">#{pitch.name}, Cycle #{pitch.cycle}</div>
            <div class="time">
              <div class="eye-icon"></div>
              <span id="remaining-time">#{moment(Date.parse(pitch.created)).fromNow()}</span>
            </div>
            #{ if pitch.overdue then '<div class="eye-icon"></div> <div class="status">Past</div>' else ""}
          </div>

          <div class="pitch-card-footer">
            <div class="learners" title="Demo date"> #{moment.utc(pitch.demo_date).format('LL')}</div>
            <div class="more-icon">
              <ul class="dropdown-option">
                <li class="dropdown-item edit"><a class="edit" href="/pitch/#{pitch.pitch_id}/edit">Edit Pitch</a></li>
                <li data-id="#{pitch.pitch_id}" class="dropdown-item delete">
                  <a class="delete">Delete</a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </span>
      """
    else
      pitchDetails = """
        <span onclick='window.location = "pitch/#{pitch.pitch_id}"'>
        <div class="pitch-card">
          <div class="body" onclick='window.location = "pitch/#{pitch.pitch_id}"'>
            <div class="title">#{pitch.name}, Cycle #{pitch.cycle}</div>
            <div class="time">
              <div class="eye-icon"></div>
              <span id="remaining-time">#{moment(Date.parse(pitch.created)).fromNow()}</span>
            </div>
          </div>
          <div class="pitch-card-footer">
            <div class="learners" title="Demo date"> #{moment.utc(pitch.demo_date).format('LL')}</div>
          </div>
        </div>
        </span>
      """
    $(".pitches-grid").append(pitchDetails)

  openDeleteConfirmationModal: ->
    self = @
    $(".dropdown-item.delete").off 'click'
    $(".dropdown-item.delete").on 'click', ->
      self.pitchId = $(this)[0].dataset.id
      self.deleteConfirmationModal.open()
      self.closeDeleteConfirmationModal()
      self.deletePitch(self.pitchId)

  closeDeleteConfirmationModal: ->
    self = @
    $('.close-delete-modal, .cancel-btn').on 'click', ->
      self.deleteConfirmationModal.close()

  deletePitch: (pitchId) ->
    self = @
    $('#confirm-delete-pitch').off 'click'
    $('#confirm-delete-pitch').on 'click', ->
      self.api.deletePitch(pitchId, self.flashErrorMessage)
        .then((data) -> (
          if data.error
            self.flashErrorMessage(data.error)
            self.deleteConfirmationModal.close()
          else
            self.flashSuccessMessage(data.message)
            window.location.reload()
        ))

  fetchPitchLearners: =>
    self = @
    if pageUrl[1] == 'pitch' && pageUrl.length == 3
      self.api.getPitchData(self.learnersContentPerPage, self.learnerPagination.page)
        .then((data) -> (
          self.panelist = data.campers_details.panelist
          self.learnersData = data.campers_details.paginated_data
          self.pitchlearnersCount = data.campers_details.data_count
          self.populateLearners(self.learnersData)
          self.learnerPagination.initialize(
            self.pitchlearnersCount, self.api.getPitchData,
            self.populateLearners, self.learnersContentPerPage,
            {}, ".pagination-control.learners-pitch-pagination"
          )
        ))

  fetchPitchLearnerAverage: =>
    self = @
    $("#summary-tab").click(->
      if pageUrl[1] == 'pitch' && pageUrl.length == 3
        self.api.getPitchData(self.summaryContentPerPage, self.summaryPagination.page)
          .then((data) -> (
            self.summaryPagination.initialize(
              data.avg_ratings.data_count, self.api.getPitchData,
              self.populatePitchLearnerAverage, self.summaryContentPerPage,
              {}, ".pagination-control.summary-page-pagination"
            )
            self.populatePitchLearnerAverage(data.avg_ratings.paginated_data)
          ))
    )

  populatePitchLearnerAverage: (learnersAverage) =>
    self = @
    $("#pitch-summary-data").html("")
    if learnersAverage.length
      learnersAverage.forEach((learner) ->
        self.populatePitchLearnerRow(learner)
      )

  populatePitchLearnerRow: (learnerAverage) =>
    self = @
    summary = """
    <tr class='pitch-summary' id="">
      <td class='mdl-data-table__cell--non-numeric'>
        <a href='#{pageUrl[2]}/ratings/#{learnerAverage.camper_id}' class='one-learner-breakdown'>
          #{learnerAverage.first_name} #{learnerAverage.last_name}
        </a>
      </td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage.avg_ui_ux).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage.avg_api_functionality).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage.avg_error_handling).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage.avg_project_understanding).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage.avg_presentational_skill).toFixed(1)}</td>
      <td class='mdl-data-table__cell--non-numeric'>#{Number(learnerAverage.cumulative_average).toFixed(1)}</td>
    </tr>

    """
    $("#pitch-summary-data").append(summary)

  populateLearners: (learnersData) =>
    self = @
    $(".panelist-cards").html("")
    if learnersData.length
      $(".with-learners").removeClass("hide")
      learnersData.forEach((learner) ->
        self.populatePitchLearnersCard(learner)
      )
      return self.learnerModal.start()

    $(".with-learners").addClass("hide")
    $(".no-learners").removeClass("hide")

  populatePitchLearnersCard: (learnersData) ->
    self = @
    if learnersData.is_graded == false
      learnerDetails = """
          <a href="/pitch/#{learnersData.pitch_id}/#{learnersData.id}" class="panelist-card mdl-cell mdl-cell--3-col mdl-cell--8-col-tablet">
            <div class="panelist-card__content">
              <div class="persona-img">
              <img src="https://ui-avatars.com/api/?name=#{learnersData.first_name.slice(0, 1)}+%20#{learnersData.last_name.slice(0, 1)}&background=195BDC&color=fff&size=128" alt="learner image">
              </div>
              <div class="persona-name">#{learnersData.first_name} #{learnersData.last_name}</div>
              <div class="persona-mail">#{learnersData.email}</div>
              <div class="persona-badge">Not rated yet</div>
            </div>
          """
    else
      learnerDetails = """
        <a href="#" class="panelist-card mdl-cell mdl-cell--3-col mdl-cell--8-col-tablet rated-learner-message">
          <div class="panelist-card__content" id="#{learnersData.id}">
            <div class="persona-img">
            <img src="https://ui-avatars.com/api/?name=#{learnersData.first_name.slice(0, 1)}+%20#{learnersData.last_name.slice(0, 1)}&background=195BDC&color=fff&size=128" alt="learner image">
            </div>
            <div class="persona-name">#{learnersData.first_name} #{learnersData.last_name}</div>
            <div class="persona-mail">#{learnersData.email}</div>
            <div class="persona-badge-active">Rated</div>
          </div>
        """
    $(".panelist-cards").append(learnerDetails)

  ratedLearnerMessage: ->
    self = @
    $('.rated-learner-message').off("click").click ->
      self.flashErrorMessage("This learner has already been rated")

  populateFields: (pitch) ->
    @pitch_id = pageUrl[2]
    @pitch_date = pitch.demo_date
    @program = pitch.program_name
    @program_id = pitch.program_id
    @center_name = pitch.center_name
    @cycle_number = pitch.cycle_number
    @pitch_cycle_selected = "#{@center_name} -- #{@cycle_number}"
    @cycle_center_id = pitch.cycle_center_id
    @pitch_lfa_email = pitch.panelists
    @getProgramCycleCenter(@program_id)
    @getAllCamperInCenter(@cycle_center_id)
    $('#selected').text(@program)
    $('#pitch_cycle-value').text(@pitch_cycle_selected)
    $('.pitch-cohort').text("#{@center_name} Cohort #{@cycle_number}")
    @displayPanelistEmail(@pitch_lfa_email)
    splitted_date = @pitch_date.split('-')
    formatted_date = "#{splitted_date[1]}/#{splitted_date[2]}/#{splitted_date[0]}"
    $("#select-demo-date").datepicker("setDate",formatted_date).find('a.ui-state-highlight').addClass('ui-state-active')

    if ($('.lfa-modal-dialog').css('display') == 'none')
      $('.view-score-breakdown').text('View score breakdown')
      $('<span><i class="fa fa-angle-down"></i></span>').appendTo( $( ".view-score-breakdown" ) )
