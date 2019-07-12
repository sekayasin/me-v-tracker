class Program.App
  constructor: ->
    @api = new Program.API
    @adminAPI = new Admin.API
    @loaderUI = new Loader.UI
    @cadenceApi = new Cadence.API
    @createProgramUI = new CreateProgram.UI

  start: ->
    @createProgramUI.submitForm(@saveProgram)
    @createProgramUI.checkHolisticEvaluationStatus(@fetchCadences)

  fetchCadences: =>
    @cadenceApi.fetchCadences().then (cadences) =>
      @createProgramUI.populateCadenceDropdown(cadences)

  saveProgram: =>
    programDetails = @createProgramUI.getProgramParameters()
    @api.createProgram(programDetails).then (response) =>
      if response.program
        @loaderUI.hide()
        @createProgramUI.closeAddProgramModal()
        @createProgramUI.displayToastMessage("Program Successfully Created", "success")
        @sendAdminNotification(response.program.name)
        if pageUrl[1] == 'programs'
          location.reload()
      if response.error
        @loaderUI.hide()
        @createProgramUI.displayToastMessage(response.error, "error")

  sendAdminNotification: (programName)=>
    @adminAPI.fetchAdminEmails().then (adminEmails) ->
      if adminEmails.emails
        Notifications.App.sendAdminNewProgramNotification(adminEmails.emails, programName)
