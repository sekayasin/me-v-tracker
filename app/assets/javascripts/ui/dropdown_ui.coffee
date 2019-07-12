class Dropdown.UI

  constructor: ({
    dropdownClass = 'dropdown'
    dropdownContentClass = 'dropdown-content'
    selectValueClass = 'value'
    selectInputClass = 'dropdown-input'
    dropdownLinkClass = 'dropdown-link'
    dropdownTextClass = 'dropdown-text'}) ->

    @dropdown = document.getElementsByClassName(dropdownClass)
    @dropdownContent = document.getElementsByClassName(dropdownContentClass)
    @selectValue = document.getElementsByClassName(selectValueClass)
    @selectInput = document.getElementsByClassName(selectInputClass)
    @dropdownLink = document.getElementsByClassName(dropdownLinkClass)
    @dropdownText = document.getElementsByClassName(dropdownTextClass)

  initializeDropdown: =>
    @handleDropdownToggle()
    @handleDropdownItemClick()
  
  handleDropdownToggle: =>
    self = @
    $(@selectInput).on 'click', (event)  ->
      event.stopPropagation();
      self.toggleArrowClass()
      $(self.dropdown).find(self.dropdownContent).toggle()
    
    $(document).click ->
      self.hideDropdownContent()
      self.removeArrowClass()

  handleDropdownItemClick: =>
    self = @
    $(@dropdownLink).click ->
      text = $(this).html()
      id = $(this).parent().data().value
      $(self.selectInput).find(self.dropdownText).html text
      $(self.selectInput).find(self.dropdownText).attr("data-value", id)
      self.hideDropdownContent()
      self.addArrowClass()
  
  removeArrowClass: =>
    $(@dropdown).find(@selectInput).removeClass('up-arrow')

  addArrowClass: =>
    $(@dropdown).find(@selectInput).addClass('up-arrow')

  toggleArrowClass: =>
    $(@dropdown).find(@selectInput).toggleClass('up-arrow')

  hideDropdownContent: =>
    $(@dropdownContent).hide()
