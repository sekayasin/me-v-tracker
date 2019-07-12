$(document).ready ->
  if pageUrl[1] == 'surveys-v2'
    survey = new SurveyV2.App()
    survey.start()

    dropDown = new JqueryDropdown.App({
        selectDropdownClass: 'survey-dropdown'
    })
    dropDown.start()

    surveyTable = new SurveyTableTour.App()
    surveyTable.start()

    scrollElem = (e) -> 
        questionNumber = $('.survey-container').index(e.target.closest('.survey-container'))
        questionElem = $( ".question:contains(#{questionNumber})" )[0]
        if questionElem isnt undefined && questionNumber isnt 0
          questionElem.scrollIntoView({ behavior: 'smooth', block: 'center' })

    if pageUrl[2] is 'setup' 
      $(".setup-container.form").on("click change mousedown", scrollElem)

      surveyBuilder = new SurveyBuilderTour.App()
      surveyBuilder.start()

    if pageUrl[3] is 'edit'
      $(".setup-container.form").on("click change mousedown", scrollElem)

