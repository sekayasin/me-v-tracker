# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  if (pageUrl[1] == 'analytics' and !pageUrl[2])
    if !localStorage.getItem("programId")
      window.location = "/"
    else
      dashboardCharts = new Dashboard.App()
      dashboardCharts.start()

    startDatePicker = new JqueryDatePicker.App({
      datePickerId: 'select_start_date',
      closeText: 'CLOSE',
      dateFormat: 'dd-mm-yy',
      showButtonPanel: true
    })
    startDatePicker.start()

    endDatePicker = new JqueryDatePicker.App({
      datePickerId: 'select_end_date',
      closeText: 'CLOSE',
      dateFormat: 'dd-mm-yy',
      showButtonPanel: true
    })
    endDatePicker.start()

    centerDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'center-dropdown'
    })
    centerDropdown.start()

    cycleDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'cycle-dropdown'
    })
    cycleDropdown.start()

    userAnalyticsTour = new UserAnalyticsTour.App()
    userAnalyticsTour.start()
