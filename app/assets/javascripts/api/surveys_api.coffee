class Survey.API
  getSurveys: (size, page) ->
    return $.ajax(
      url: "/surveys?size=#{size}&page=#{page}"
      type: "GET"
      success: (data) ->
        return data
    )

  getAllCycles: (afterError) ->
    return $.ajax(
      url: "/surveys/recipients"
      type: "GET"
      error: (error) ->
        afterError()
    )

  createSurvey: (afterError, payload) ->
    return $.ajax(
      url: "/surveys"
      type: "POST"
      data: payload
      error: (error) ->
        afterError()
    )

  updateSurvey: (afterError, payload) ->
    return $.ajax(
      url: "/surveys/#{payload.survey.survey_id}/update"
      type: "PUT"
      data: payload
      error: (error) ->
        afterError()
    )

  getSurveysRecipients: (afterError, id) ->
    return $.ajax(
      url: "/surveys/#{id}/recipients"
      type: "GET"
      error: (error) ->
        afterError()
    )

  closeSurvey: (afterError, surveyId) ->
    return $.ajax(
      url: "/surveys/#{surveyId}/close"
      type: "PUT"
      error: (error) ->
        afterError()
    )
  deleteSurvey: (surveyId) =>
      return $.ajax
        url: "/surveys/#{surveyId}/delete"
        type: 'DELETE'
        success: (response) ->
          return response
        error: (error) ->
          return error
