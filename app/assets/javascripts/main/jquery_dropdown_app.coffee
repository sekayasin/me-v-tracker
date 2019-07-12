class JqueryDropdown.App
  constructor: (options = { selectDropdownClass: 'assessment' }) ->
    @ui = new JqueryDropdown.UI(options)
  
  start: ->
    @ui.initializeDropdown()
