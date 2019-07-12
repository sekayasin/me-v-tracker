$(document).ready =>
  if pageUrl[1] == "curriculum"
    learningOutcomes = new LearningOutcomes.App()
    learningOutcomes.start()
    
    frameworkDropdown = new JqueryDropdown.App({
        selectDropdownClass: "framework-filter-outcome"
    })
    frameworkDropdown.start()

    criteriumDropdown = new JqueryDropdown.App({
      selectDropdownClass: "criteria-filter-outcome"
    })
    criteriumDropdown.start()

    criteriumDropdownModal = new JqueryDropdown.App({
      selectDropdownClass: "criteria-filter-outcome-modal"
    })
    criteriumDropdownModal.start()

    frameworkDropdownModal = new JqueryDropdown.App({
      selectDropdownClass: "framework-filter-outcome-modal"
    })
    frameworkDropdownModal.start()

    programDropdownModal = new JqueryDropdown.App({
      selectDropdownClass: "program-filter-dropdown"
    })

    programDropdownModal.start()

    multipleSubmissionDropdownModal = new JqueryDropdown.App({
      selectDropdownClass: "multiple-submission-outcome-modal"
    })

    multipleSubmissionDropdownModal.start()

