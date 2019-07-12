$(document).ready ->
  program = new Program.App()
  program.start()

  allPrograms = new AllPrograms.App
  allPrograms.start()

  cloneProgramDropdown = new JqueryDropdown.App({
    selectDropdownClass: 'clone-program-dropdown'
  })
  cloneProgramDropdown.start()

  cadenceDropdown = new JqueryDropdown.App({
    selectDropdownClass: 'cadence-dropdown'
  })
  cadenceDropdown.start()
