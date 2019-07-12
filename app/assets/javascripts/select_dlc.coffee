$(document).ready =>
  if window.location.pathname == '/'
    slider = new Slider.App()
    slider.start()

  dropdown = new Dropdown.App({
  dropdownClass: 'dropdown'
  dropdownContentClass: 'dropdown-content'
  selectValueClass: 'value'
  selectInputClass: 'dropdown-input'
  dropdownLinkClass: 'dropdown-link'
  dropdownTextClass: 'dropdown-text'
  })

  dropdown.start()

  selectDlc = new SelectDlc.App()
  selectDlc.start()
