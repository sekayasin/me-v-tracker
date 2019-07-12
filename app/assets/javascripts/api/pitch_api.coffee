class Pitch.API
  getProgramCycleCenter: (program_id, afterError) ->
    return $.ajax(
      url: "/pitch/program/#{program_id}"
      type: "GET"
      error: (error) ->
        afterError(error.statusText)
  )

  getAllCampersInCenter: (cycle, afterError) ->
    return $.ajax(
      url: "/pitch/setup/#{cycle}"
      type: "GET"
      error: (error) ->
        afterError(error.statusText)
    )

  createPitch: (data, afterError) ->
    return $.ajax(
      url: "/pitch"
      type: "POST"
      data: data
      error: (error) ->
        afterError(error.statusText)
    )

  # method for GET requests on pitches
  getPitchData: (size, page) ->
    url = "/pitch/#{pageUrl[2]}"
    if pageUrl[1] == 'pitch' && pageUrl.length == 2
      url = "/pitch"
    return $.ajax(
      url: "#{url}?size=#{size}&page=#{page}"
      type: "GET"
      contentType: 'application/json'
      success: (data) ->
        return data
    )

  deletePitch: (pitchId, afterError) ->
    return $.ajax(
      url: "/pitch/#{pitchId}"
      type: "DELETE"
      success: (data) ->
        return data
      error: (error) ->
        afterError(error.statusText)
    )

  getLearnerRatings: (learnersPitchId, afterError) ->
    return $.ajax(
      url: "/pitch/show/#{learnersPitchId}"
      type: "GET"
      error: (error) ->
        afterError(error.statusText)
    )
    
  submitLearnersRating: (data, afterError) ->
    return $.ajax(
      url: "/pitch/submit_learner_ratings"
      type: "POST"
      data: data
      error: (error) ->
        afterError(error.statusText)
    )
    
  editPitch: (pitch_id) ->
    return $.ajax(
      url: "/pitch/#{pitch_id}/edit"
      type: "GET"
      success: (data) ->
        return data
    )

  updatePitch: (pitch_id, data, afterError) ->
    return $.ajax(
      url: "/pitch/#{pitch_id}"
      type: "PUT"
      data: data
      error: (error) ->
        afterError(error.statusText)
    )
