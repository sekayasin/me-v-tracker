$(document).ready =>
  if pageUrl[1] == "learner"
    learnerProfile = new LearnersProfile.App()
    learnerProfile.start()

    genderDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'gender-dropdown'
    })
    genderDropdown.start()

    countryDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'country-dropdown'
    })
    countryDropdown.start()

    cityDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'city-dropdown'
    })
    cityDropdown.start()

    learnersProfileTour = new LearnerProfileTour.App()
    learnersProfileTour.start()
