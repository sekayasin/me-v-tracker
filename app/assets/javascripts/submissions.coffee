$(document).ready =>
  submissions = new Submissions.App()
  submissions.start()

  dropDown = new JqueryDropdown.App({
    selectDropdownClass: 'learner-impression-dropdown'
  })
  dropDown.start()
