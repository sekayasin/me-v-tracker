class SurveyV2.API
  saveSurvey: (survey, afterError) ->
    return $.ajax(
      url: "/surveys-v2"
      type: "POST"
      data: survey
      processData: false
      contentType: false
      error: (error) ->
        afterError(error)
    )

  getSurveysV2: (size, page) ->
    return $.ajax(
      url: "/surveys-v2?size=#{size}&page=#{page}"
      type: "GET"
      success: (data) ->
        return data
    )

  submitResponse: (response, survey_id, afterError) ->
    return $.ajax(
      url: "/surveys-v2/respond/#{survey_id}"
      type: "POST"
      data: response
      processData: false
      contentType: false
      error: (error) ->
        afterError(error)
    )

  getSurvey: (survey_id, afterError) -> 
    return $.ajax(
      url: "/surveys-v2/respond/#{survey_id}"
      type: "GET"
      success: (data) ->
        return data
    )

  getActiveCycles: (afterError) ->
    return $.ajax(
      url: "/surveys-v2/recipients"
      type: "GET"
      error: (error) ->
        afterError(error)
    )
    
  cloneSurvey: (survey_id, afterError) ->
    return $.ajax(
      url: "/surveys-v2/clone"
      type: "POST"
      data: { survey_id }
      error: (error) ->
        afterError(error)
    )
  deleteSurveys: (surveyId, afterError) ->
    return $.ajax(
      url: "/surveys-v2/#{surveyId}"
      type: "DELETE"
      error: (error) ->
        afterError(error)
    )

  editSurvey: (surveyId, afterError) ->
    return $.ajax(
      url: "/surveys-v2/#{surveyId}/edit"
      type: "GET"
      error: (error) ->
        afterError(error)
    )

  updateSurvey: (survey, afterError) ->
    return $.ajax(
      url: "/surveys-v2/update"
      type: "PUT"
      data: survey
      processData: false
      contentType: false
      error: (error) ->
        afterError(error)
    )

  getSurveyResponses: (survey_id, afterError) ->
    return $.ajax(
      url: "/surveys-v2/responses/#{survey_id}"
      type: "GET"
      contentType: 'application/json'
      success: (data) ->
        return data
    )

  shareSurvey: (payload, afterError) ->
     return $.ajax(
       url: "/surveys-v2/share-responses"
       type: "POST"
       data: payload
       contentType: "application/json"
       success: (data) ->
         return data
     )
  getAllAdmin: (afterError) ->
    return $.ajax(
      url: "/admins"
      type: "GET"
      success: (data) ->
        return data
    )

  getASurvey: (surveyId, afterError) ->
    return $.ajax(
      url: "/surveys-v2/show/#{surveyId}"
      type: "GET"
      error: (error) -> 
    )

  getSurveyRespondent: (afterError) ->
    return $.ajax(
      url: "/surveys-v2/respondents"
      type: 'GET'
      error: (error) ->
        afterError(error)
    )

  getSurveyResponseData: (survey_id, afterError) ->
    return $.ajax(
      url: "/surveys-v2/respond/#{survey_id}/edit"
      type: "GET"
      contentType: 'application/json'
      error: (error) ->
        afterError(error)
    )

  toggleArchiveSurvey: (data, afterError) ->
    return $.ajax(
      url: "/surveys-v2/toggle-archive"
      type: "PUT"
      data: data
      error: (error) ->
        afterError(error)
    )
