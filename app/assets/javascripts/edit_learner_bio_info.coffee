$(document).ready ->
  if pageUrl[1] == "learners"
    editLearnerBioInfo = new EditLearnerBioInfo.App()
    editLearnerBioInfo.start()

    learnerCountryDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'learner-country-dropdown'
    })
    learnerCountryDropdown.start()

    learnerCityDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'learner-city-dropdown'
    })
    learnerCityDropdown.start()

    learnerGenderDropdown = new JqueryDropdown.App({
      selectDropdownClass: 'learner-gender-dropdown'
    })
    learnerGenderDropdown.start()
