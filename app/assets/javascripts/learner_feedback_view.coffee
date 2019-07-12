$(document).ready ->
  learnerFeedbackView = new LearnerFeedbackView.App()
  learnerFeedbackView.start()

  learnerSelectMenu = new JqueryDropdown.App({
    selectDropdownClass: 'learner-select-menu'
  })
  learnerSelectMenu.start()
