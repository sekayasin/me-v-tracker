class AddLearner.App
  constructor: ->
    @addLearnerUI = new AddLearner.UI()
    @addLearnerAPI = new AddLearner.API()
    @columnFilterUI = new ColumnFilter.UI()
    @learnersTableUI = new LearnersTable.UI()
    @learnersDashboardApi = new LearnersDashboard.API()
    @learnersDashboardApp = new LearnersDashboard.App()
    @learnersDashboardUI = new LearnersDashboard.UI()
    @infiniteScrollUI = new InfiniteScroll.UI()
    @infiniteScrollApi = new InfiniteScroll.API()
    @observer = new Observer.App()
    @learnerData = new FormData()
    @loaderUI = new Loader.UI()
    @city = ''
    @programName = ''
    @programId = 0
    @programCycle = 0
  
  start: =>
    @addLearnerUI.openAddLearnerModal()
    @addLearnerUI.showFirstTab()
    @showNextTab()
    @addLearnerUI.showPreviousTab()
    @addLearnerUI.resetTabState()
    @addLearnerUI.validateDropdowns()
    @addLearnerUI.validateFormInput()
    @addLearnerUI.selectCountry()
    @addLearnerUI.updateUploadedFileName()
    @updateDlcOptions()

  showNextTab: =>
    self = @
    $('#rightBtn').on 'click', (event) ->
      if $(this).hasClass('show-second-tab')
        self.addLearnerUI.showSecondTab()
        return
      if $(this).hasClass('post-form-request')
        self.submitForm()
        return

      if $(this).hasClass('view-cycle')
        self.goToCurrentCycle()
        return

  # get url with filter params for newly uploaded program/cycle
  getCurrentUploadedLearners: =>
    self = @
    baseUrl = window.location.protocol + '//' + window.location.host + '/learners?'
    Object.keys(self.addLearnerUI.filterParam).forEach (parent) ->
      baseUrl += parent + '=' + self.addLearnerUI.filterParam[parent] + '&'
      return
    return baseUrl.substr(0, baseUrl.length - 1)

  uploadLearners: (learnerData) =>
    self = @
    self.addLearnerAPI.saveLearnersData(learnerData).then((data) ->
      if data && data.error
        self.addLearnerUI.showError(data)
        return
      Notifications.App.sendLfaNewLearnerNotification(data[1])
      self.addLearnerUI.showWarning(data[0])
      self.addLearnerUI.clearError()
      self.addLearnerUI.completeUploadLearner()
    )
    return
  
  # prepare learners upload form params
  prepareParams: (serializedData) =>
    self = @
    $.each serializedData, (key, input) =>
      switch input.name
        when 'country' 
          self.learnerData.append('country', input.value)
        when 'select_program'
          self.programId = input.value
          self.programName = $("#select_program option[value='#{input.value}']").text()
          self.learnerData.append('program_id', input.value)
          self.addLearnerUI.filterParam.program_id = input.value
        when 'select_dlc_stack'
          self.learnerData.append('dlc_stack_id', input.value)
        when 'select_start_date'
          self.learnerData.append('start_date', input.value)
        when 'select_end_date'
          self.learnerData.append('end_date', input.value)
        when 'select_city'
          self.city = input.value
          self.learnerData.append('city', input.value)
          self.addLearnerUI.filterParam.city = input.value
        when 'enter_cycle_number'
          self.programCycle = input.value
          self.learnerData.append('cycle', input.value)
          self.addLearnerUI.filterParam.cycle = input.value
        else 
          self.learnerData.append(input.name, input.value)
      return

    fileData = $('input[name="upload_learners_file"]')[0].files[0]
    self.learnerData.append('file', fileData)

  updateDlcOptions: =>
    self = @
    $("#select_program").on 'selectmenuchange', (event) ->
      event.stopPropagation()
      programId = parseInt @value
      if programId > 0
        self.addLearnerAPI.getProgramDlcStack(programId).then((dlcStacks) ->
          self.addLearnerUI.populateDlcStackDropdown('#select_dlc_stack', dlcStacks)
        )

  redirectToProgram: (programId, programName) ->
    localStorage.setItem('programId', programId)
    $('.program-text-display').attr("data-value", programId).html(programName)
    $('.learners-type').html('Recently Uploaded Learners')
    $('.pane-vScroll').css('overflow-y', 'auto')
    $('.campers-data-table').removeClass('hidden')
    $('.export-btn').css('display', 'none')
    baseUrl = window.location.protocol + '//' + window.location.host + '/learners?program_id=' + programId
    window.history.replaceState(null, null, baseUrl)

  submitForm: ->
    self = @
    if $('#addLearnerForm').valid()
      self.loaderUI.show()
      serializedData = $('#addLearnerForm').serializeArray()
      self.prepareParams(serializedData)
      self.addLearnerAPI.checkProgramExists(self.programId, self.city, self.programCycle).then((existingProgram) ->
        if existingProgram
          self.loaderUI.hide()
          self.addLearnerUI.openConfirmUploadModal()
          self.confirmUpload()
          self.addLearnerUI.cancelUpload()
        else
          self.uploadLearners(self.learnerData)
      )
      return

  confirmUpload: ->
    self = @
    $('#confirm-upload-learner').on 'click', (event) =>
      event.stopImmediatePropagation()
      self.loaderUI.show()
      self.addLearnerUI.closeConfirmUploadModal()
      self.uploadLearners(self.learnerData)

  goToCurrentCycle: ->
    self = @
    self.addLearnerUI.showCurrentCycle()
    self.infiniteScrollApi.getCampersRecord(self.getCurrentUploadedLearners() + "&page=1")
    self.observer.setMutationObserver(
      self.infiniteScrollUI.getTableRecords('#campers-table-records'),
      self.beforeRedirectToProgram
    )
    self.redirectToProgram(self.programId, self.programName)
    self.addLearnerUI.addLearnerModal.close()
    self.addLearnerUI.resetModalStatus()

  beforeRedirectToProgram: (addedElements) =>
    self = @
    self.columnFilterUI.hideUncheckedColumn()
    self.learnersDashboardUI.closeDecisionAndLFADropdownsByIcon()
    self.learnersTableUI.updateDecisionsDropdownState()
