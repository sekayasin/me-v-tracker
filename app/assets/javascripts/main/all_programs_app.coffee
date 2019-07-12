class AllPrograms.App
  constructor: ->
    @ProgramAPI = new Program.API
    @allProgramsUI = new AllPrograms.UI(@ProgramAPI)

  start: =>
    @allProgramsUI.openAllPrograms(@ProgramAPI.getAllPrograms)
    @allProgramsUI.goToProgram()
    @allProgramsUI.programDetails()
