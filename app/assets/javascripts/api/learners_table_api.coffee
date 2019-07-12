class LearnersTable.API
  fetchFilterMeta: (url) =>
    return $.ajax
      type: 'GET'
      url: url
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'

  updateLearnerLfa: (data, learnerProgramId) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/learners/lfa-update/#{learnerProgramId}"
        type: 'PUT'
        data: data
        success: ->
          resolve()
        error: ->
          reject()
    )
