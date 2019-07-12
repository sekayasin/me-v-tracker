class AddFacilitator.App
  constructor: ->
    @addFacilitatorUI = new AddFacilitator.UI()

  start: =>
    @addFacilitatorUI.openAddFacilitatorModal()
    @addFacilitatorUI.showNextTab()
    @addFacilitatorUI.showFirstTab()
    @addFacilitatorUI.showPreviousTab()
    @addFacilitatorUI.resetTabState()
    @addFacilitatorUI.validateFormInput()
    @addFacilitatorUI.selectCountry()
    @addFacilitatorUI.initializeSelectWeek()
