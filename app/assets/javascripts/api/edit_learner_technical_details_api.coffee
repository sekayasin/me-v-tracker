class EditLearnerTechnicalDetails.API
  fetchLearnerTechnicalDetails: ->
    return $.ajax(
      url: "/learner/get_learner_technical_details"
      type: 'GET'
      success: (data) ->
        return data
    )

  updateLearnerTechnicalDetails: (details) ->
    return $.ajax(
      url: "/learner/update_learner_technical_details"
      type: 'PUT'
      data: details: details
      success: (data) ->
        return data
    )
