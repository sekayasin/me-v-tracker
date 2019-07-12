class ProgramFeedbackChart.API
  getProgramFeedback: (programId, center, cycle) ->
    return $.ajax(
      url: "/programs/#{programId}/centers/#{center}/cycles/#{cycle}/program-feedback"
      type: "GET"
    )

  fetchProgramFeedbackCenters: (programId) ->
    return $.ajax(
      url: "/programs/#{programId}/feedback-centers"
      type: "GET"
    )
