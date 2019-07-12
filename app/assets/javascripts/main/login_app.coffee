class Login.App
  constructor: ->
    @ui = new Login.UI()
    @api = new Login.API()

  start: =>
    @ui.getCredentials(@loginRequest)
    @ui.validateFormInput()

  loginRequest: (data, api_url) =>
    self = @
    self.api.LoginUser(JSON.stringify(data), api_url)
    .then (response) ->
      document.cookie = "jwt-token= #{response['auth_token']};\
        domain=andela.com;"
      location.href = "/"
    .catch (error) ->
      self.ui.revealToast(error.responseJSON.error, "error")
