$(document).ready =>
  if pageUrl[1] == "curriculum"
    programDetails = new ProgramDetails.App()
    programDetails.start()

  if pageUrl[1] == "programs"
    stackDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'stack-dropdown'
    })
    stackDropdown.start()
