class Dropdown.App
  constructor: (options = {
    dropdownClass: 'dropdown'
    dropdownContentClass: 'dropdown-content'
    selectValueClass: 'value'
    selectInputClass: 'dropdown-input'
    dropdownLinkClass: 'dropdown-link'
    dropdownTextClass: 'dropdown-text' }) ->
    @ui =
    new Dropdown.UI(options)
  
  start: =>
    @ui.initializeDropdown()