class SelectDlc.UI
  getSelectedValue: (id, childElement) =>
    $(id).find(childElement).html()

  selectDlcError: (element, errorMessage, redirectErrorElement) =>
    if ($(element).is(':empty') && $(redirectErrorElement).text().trim() == '')
      $(element).html(errorMessage)

  getLearnerData: (triggerElement, targetElement, childElement, redirectFunction) =>
    self = @
    $(triggerElement).click (event) ->
      event.preventDefault()
      programId = self.getSelectedValue(targetElement, childElement)
      if programId != undefined
        redirectFunction(programId)
      else
        self.selectDlcError('#program-select-error', '<p>Please select an ALC program to proceed</p>', '#redirect-error')
    $('#sample .dropdown-link').click ->
      localStorage.setItem('programId', $(@).parent().attr('data-value'))
