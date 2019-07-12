class Cadence.API
  fetchCadences: () ->
    request = $.ajax(
      url: "/cadences"
      type: 'GET'
      dataType: 'json'
      success: (data) ->
        return data
    )
