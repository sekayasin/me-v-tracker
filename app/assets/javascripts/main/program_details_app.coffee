class ProgramDetails.App
  constructor: ->
    @programDetailsUI = new ProgramDetails.UI(localStorage.getItem("programId"))
    @programDetailsApi = new ProgramDetails.API()

  start: ->
    self = @
    self.programDetailsUI.fetchProgramDetails(
      self.programDetailsApi.getProgramDetails
    )
