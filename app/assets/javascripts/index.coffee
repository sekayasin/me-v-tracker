# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  messageToast = new MessageToast.App()
  $.fn.messageToast = messageToast

  new Header.App()

  headerDropdown = new Dropdown.App({
    selectInputClass: 'program-select'
    dropdownTextClass: 'dropdown-text'
    dropdownClass: 'program-dropdown'
  })
  headerDropdown.start()

  logoutDropdown = new Dropdown.App({
    dropdownClass: 'logout-dropdown',
    selectInputClass: 'logout-select',
  })

  logoutDropdown.start()

  if pageUrl[1] is "programs"
    allPrograms = new AllPrograms.App()
    allPrograms.start()
    if pageUrl[3]
      editLearnerProgramsTour = new EditLearnerProgramsTour.APP()
      editLearnerProgramsTour.start()
    else
      programsPageTour = new ProgramsPageTour.APP()
      programsPageTour.start()

  if (pageUrl[1] == 'learners' and pageUrl.length == 2)
    learnersApp = new LearnersDashboard.App()
    learnersApp.start()

    columnFilter = new ColumnFilter.App()
    columnFilter.start()

    learnersTable = new LearnersTable.App()
    learnersTable.start()

    addLearner = new AddLearner.App()
    addLearner.start()

    addFacilitator = new AddFacilitator.App()
    addFacilitator.start()

    selectDetailDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'select-detail'
    })
    selectDetailDropdown.start()

    startDatePicker = new JqueryDatePicker.App({
      datePickerId: 'select_start_date',
      minDate: '0D',
      closeText: 'CLOSE',
      dateFormat: 'dd-mm-yy',
      showButtonPanel: true
    })
    startDatePicker.start()

    endDatePicker = new JqueryDatePicker.App({
      datePickerId: 'select_end_date',
      minDate: '0D',
      closeText: 'CLOSE',
      dateFormat: 'dd-mm-yy',
      showButtonPanel: true
    })
    endDatePicker.start()

    learnersPageTour = new LearnersPageTour.App()
    learnersPageTour.start()
    
  if pageUrl[1] == "submissions"
    if pageUrl[2]
      learnerSubmissionsTour = new LearnerSubmissionsTour.App()
      learnerSubmissionsTour.start()
    else
      submissionsPageTour = new SubmissionsPageTour.App()
      submissionsPageTour.start()
