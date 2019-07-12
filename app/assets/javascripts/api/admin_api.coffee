class Admin.API
  fetchAdminEmails: ->
    return $.ajax(
      url: '/admins'
      type: 'GET'
      success: (data) ->
        return data
    )
