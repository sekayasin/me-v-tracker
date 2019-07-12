class ProgramEdit.App
  constructor: ->
    @programId = parseInt(pageUrl[2])
    @adminAPI = new Admin.API
    @programEditApi = new ProgramEdit.API
    @programEditUI = new ProgramEdit.UI(
      @programEditApi.submitProgramDetails,
      @programId
      @sendAdminNotification,
    )

  start: ->
    if pageUrl.length is 4 and pageUrl[1] is "programs" and pageUrl[3] is "edit"
      @programEditApi.getProgramDetails(parseInt(pageUrl[2]), (details) => @programEditUI.setProgramDetails(details))

  sendAdminNotification: (program)=>
    @adminAPI.fetchAdminEmails().then (adminEmails) ->
      if adminEmails.emails
        Notifications.App.sendAdminFinalizedProgramNotification(adminEmails.emails, program)
