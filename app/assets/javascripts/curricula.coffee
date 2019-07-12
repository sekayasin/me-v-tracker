# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready =>
  if (pageUrl[1] == 'curriculum')
    if !localStorage.getItem "programId"
      window.location = "/learners"

    else
      curriculum = new Curriculum.App()
      curriculum.start()

      criteriumDropdown = new JqueryDropdown.App({
        selectDropdownClass: 'criterium-filter'
      })
      criteriumDropdown.start()

    curriculumsPageTour = new CurriculumsPageTour.App()
    curriculumsPageTour.start()
