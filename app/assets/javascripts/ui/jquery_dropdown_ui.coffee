class JqueryDropdown.UI
  constructor: ({ selectDropdownClass = 'assessment' }) ->
    @dropdownSelect = document.getElementsByClassName(selectDropdownClass)

  initializeDropdown: ->
    @initializeJquerySelect()
  
  initializeJquerySelect: ->
    $(@dropdownSelect).selectmenu();
