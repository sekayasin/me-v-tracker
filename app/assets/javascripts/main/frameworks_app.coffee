class Frameworks.App
  constructor: ->
    @frameworksUI = new Frameworks.UI()
    @frameworksAPI = new Frameworks.API()
    @curriculumApi = new Curriculum.API()
    @programId = localStorage.getItem('programId')

  start: ->
    @frameworksUI.initializeFrameworksTab(@getFrameworks)
    @frameworksUI.submitFrameworkForm(@updateFramework)

  getFrameworks: =>
    self = @
    self.curriculumApi.fetchCurriculumDetails(self.programId).then (curriculumDetails) ->
      self.frameworksUI.populateFrameworksTable(curriculumDetails)

  updateFramework: (frameworkId, details) =>
    self = @
    self.frameworksAPI.updateFramework(frameworkId, details).then (response) ->
      if response.message
        self.frameworksUI.showToastNotification(response.message, "success")
        self.frameworksUI.closeFrameworkModal()
        self.getFrameworks()
      else if response.error
        self.frameworksUI.showToastNotification(response.message, "error")
      
      self.frameworksUI.loaderUI.hide()
