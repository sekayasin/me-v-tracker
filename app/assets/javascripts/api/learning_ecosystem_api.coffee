class LearningEcosystem.API

  fetchPhases: (afterPhasesFetch) ->
    return $.ajax(
      url: "/learner/ecosystem/phases"
      type: 'GET'
      success: (data) ->
        afterPhasesFetch(data)
    )

  fetchOutput: (assessmentId, afterFetch, phaseId) =>
    return $.ajax(
      url: "/learner/output/view?assessmentId=#{assessmentId}&phaseId=#{phaseId}"
      type: 'GET'
      success: (data) ->
        afterFetch(assessmentId, data)
    )

  submitOutput: (output, afterSubmit) =>
    return $.ajax(
      url: "/output/submit"
      type: "POST",
      contentType: false
      data: output
      cache: false,
      processData: false,
      success: (response) ->
        afterSubmit(response)
    )

  updateOutput: (output, afterUpdate) ->
    return $.ajax(
      url: "/output/update"
      type: "PUT",
      contentType: false
      data: output
      cache: false,
      processData: false,
      success: (response) ->
        afterUpdate(response)
    )

  fetchAssessmentsPhases: (assessmentId, phaseId) ->
    return $.ajax(
      url: "/assessments/submissions/#{assessmentId}?phaseId=#{phaseId}"
      type: 'GET'
      success: (response) ->
        return response
      error: (error) ->
        return error
    )
