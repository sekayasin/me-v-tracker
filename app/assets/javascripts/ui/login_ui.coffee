class Login.UI
  getCredentials: (loginRequest) ->
    $("#login-learner").click (event)  ->
      $("#learner-login-form").validate()
      event.preventDefault()
      if $("#learner-login-form").valid()
        data = {
          email: $("#learners_email").val(),
          password: $("#learners_password").val()
        }

        loginRequest(data, $('#api_url').val())

  revealToast: (message, status) ->
    $('.toast').messageToast.start(message, status)

  validateFormInput: ->

    $('#learner-login-form').validate
      focusInvalid: false
      ignore: []
      rules:
        learners_email: "required"
        learners_password: "required"

      errorPlacement: (error, element) ->
        error.insertAfter(element)
