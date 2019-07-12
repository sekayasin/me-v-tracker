class ProgramDetails.API
  getProgramDetails: (programId) ->
    return $.ajax(
      url: "/programs/#{programId}/assessments"
      type: "GET"
      success: (data) ->
        return data
    )
