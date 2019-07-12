class EditLearnerBioInfo.UI
  constructor: ->
    @modal = new Modal.App("#edit-learner-bio-info-modal", 525, 525, 516, 516)
    @loaderUI = new Loader.UI()

  openEditLearnerModal: =>
    self = @
    $(".edit-learner-icon").on "click", (event) ->
      self.resetModal()
      self.modal.open()
      $(".learner-country").selectmenu("option", "disabled", true)
      $(".city").selectmenu("option", "disabled", true)
      $("#error-message").html("").removeClass("warning")
      cityName = $("span#camper-city").html()
      $(".city").html("")
      $(".city").append "<option selected value=#{cityName}>#{cityName}</option>"
      $(".city").val(cityName).selectmenu("refresh")
      $("body").css("overflow", "hidden")

  closeEditLearnerModal: =>
    self = @
    $(".cancel-learner-info, .close-button").on "click", (event) ->
      self.resetModal()
    $("#edit-learner-bio-info-modal").on "keydown", (evt) ->
      if evt.keyCode == $.ui.keyCode.ESCAPE
        self.resetModal()
      
  resetModal: =>
    @modal.close()
    $("body").css("overflow", "auto")
    $(".learner-email").val($("p#camper-email").html())
    $(".learner-country").val($("span#camper-country").html()).selectmenu("refresh")
    cityName = $("span#camper-city").html()
    $(".city").append "<option selected value=#{cityName}>#{cityName}</option>"
    $(".city").val(cityName).selectmenu("refresh")
    $(".gender").val($("p#camper-gender").html()).selectmenu("refresh")
      
  toggleDropdown: =>
    $(".learner-country-dropdown").on "selectmenuopen", (event, ui) ->
      $(".learner-location").find(".ui-icon").addClass("ui-icon-up")
    $(".learner-country-dropdown").on "selectmenuselect", (event, ui) ->
      $(".learner-location").find(".ui-icon").removeClass("ui-icon-up")
    $(".learner-country-dropdown").on "selectmenuclose", (event, ui) ->
      $(".learner-location").find(".ui-icon").removeClass("ui-icon-up")

    $(".learner-city-dropdown").on "selectmenuopen", (event, ui) ->
      $(".learner-city").find(".ui-icon").addClass("ui-icon-up")
    $(".learner-city-dropdown").on "selectmenuselect", (event, ui) ->
      $(".learner-city").find(".ui-icon").removeClass("ui-icon-up")
    $(".learner-city-dropdown").on "selectmenuclose", (event, ui) ->
      $(".learner-city").find(".ui-icon").removeClass("ui-icon-up")

    $(".learner-gender-dropdown").on "selectmenuopen", (event, ui) ->
      $(".learner-gender").find(".ui-icon").addClass("ui-icon-up")
    $(".learner-gender-dropdown").on "selectmenuselect", (event, ui) ->
      $(".learner-gender").find(".ui-icon").removeClass("ui-icon-up")
    $(".learner-gender-dropdown").on "selectmenuclose", (event, ui) ->
      $(".learner-gender").find(".ui-icon").removeClass("ui-icon-up")

  learnerBioInfo: (updateLearnerInfo) =>
    self = @
    $(".save-learner-info").click (event) ->
      self.loaderUI.show()
      learnerInfo = {
        email: $(".learner-email").val()
        country: $(".learner-country option:selected").text()
        city: $(".city option:selected").text()
        gender: $(".gender option:selected").text()
      }
      regex = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
      email = regex.test(learnerInfo["email"])
      if (learnerInfo["email"].trim().length == 0 || email == false)
        self.toastMessage("Please enter a valid email", "error")
      else
        self.updateLearnerBioInfo(learnerInfo, updateLearnerInfo)

  updateLearnerBioInfo: (learnerInfo, updateLearnerInfo) =>
    self = @
    updateLearnerInfo(learnerInfo).then (response) ->
      if response.saved
        learner = response.data
        $("#camper-email").text(learner.learner.email)
        $("#camper-country").text(learner.country)
        $("#camper-city").text(learner.city)
        $("#camper-gender").text(learner.learner.gender)
        self.resetModal()
        self.toastMessage("Learner Information updated successfully", "success")
        $("body").css("overflow", "auto")
      else
        $("body").css("overflow", "auto")
        self.handleResponseErrors(response.errors)

  handleResponseErrors: (errors) ->
    for entry in Object.entries(errors)
      for message in entry[1]
        @toastMessage("#{entry[0]} #{message}", "error")

  getLearnerCountry: (getLearnerCountry) =>
    $(".learner-country").on "selectmenuchange", ->
      country = $(".learner-country option:selected").text()
      getLearnerCountry(country).then (data) ->
        if data
          $(".city").html("")
          $.each data, (val, text) ->
            $(".city").append $("<option></option>").val(val).html(text)
        $("select").selectmenu("destroy").selectmenu({ style: "dropdown" })

  toastMessage: (message, status) =>
    self = @
    self.loaderUI.hide()
    $(".toast").messageToast.start(message, status)

  initializeEditLearnerBioInfo: (updateLearnerInfo, getLearnerCountry) =>
    @openEditLearnerModal()
    @toggleDropdown()
    @closeEditLearnerModal()
    @learnerBioInfo(updateLearnerInfo)
    @getLearnerCountry(getLearnerCountry)
