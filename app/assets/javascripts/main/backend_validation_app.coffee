class BackendValidation.App
  toastMessage: (elementToObserve, successMessage, errorMessage, phaseErrorMessage) =>
    self = @
    observer = new MutationObserver((mutations) ->
      @disconnect()
      saveStatus = $(mutations[0].target).attr("data-value")
      if saveStatus == "success"
        $('.toast').messageToast.start(successMessage, "success")
      else if saveStatus == "phase-error"
        $('.toast').messageToast.start(phaseErrorMessage, "error")
      else
        $('.toast').messageToast.start(errorMessage, "error")
      return
    )
    config = { attributes: true }
    observer.observe(elementToObserve, config)
