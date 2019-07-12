class Frameworks.API
  updateFramework: (frameworksId, frameworkDetails) ->
    return $.ajax(
      url: "/framework/#{frameworksId}/description"
      type: 'PUT'
      data: { framework: frameworkDetails }
      dataType: 'json'
      success: (data) ->
        return data
    )
