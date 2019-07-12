class Login.API
  LoginUser: (userData, api_url) ->
    new Promise((resolve, reject) ->
      $.ajax
        url: api_url
        type: 'POST'
        data: userData
        cache: false
        processData: false
        contentType: "application/json"
        success: (data) ->
          resolve data
        error: (error) ->
          reject error
    )
