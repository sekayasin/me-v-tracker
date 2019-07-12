class EditLearnerBioInfo.API
  learnerInfo: (learnerInfo) ->
    request = $.ajax(
      type: 'PUT'
      url: 'update-learner'
      data: learner_info: learnerInfo
      dataType: 'json'
    )
    return request

  getLearnerCity: (country) ->
    request = $.ajax(
      type: 'GET'
      url: 'get-learner-city'
      data: country: country
      dataType: 'json'
    )
    return request
