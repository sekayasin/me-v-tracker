if (pageUrl[1] == 'learners' && pageUrl[4] == 'scores')
  $(document).ready ->
    socialLinks = new Profile.App()
    socialLinks.start()

    evaluationDropdown = new Dropdown.App({
      dropdownClass: 'evaluation-dropdown',
      selectInputClass: 'evaluation-select',
    })
    evaluationDropdown.start()

    assessmentDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'assessment'
    })
    assessmentDropdown.start()

    assessmentRatingDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'assessment-rating'
    })
    assessmentRatingDropdown.start()

    decisionDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'decision-dropdown'
    })
    decisionDropdown.start()

    satisfactionDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'satisfaction-level'
    })
    satisfactionDropdown.start()

    learnerScore = new LearnerScore.App()
    learnerScore.start()

    selectMenu = new JqueryDropdown.App({
      selectDropdownClass: 'select-menu'
    })
    selectMenu.start()

    learnerProfileTour = new LearnersProfileTour.App()
    learnerProfileTour.start()
