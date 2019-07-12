class LearningOutcomes.API
  fetchLearningOutcomes: (programId, path) ->
    return $.ajax(
      url: "/output/details?program_id=#{programId}&#{path}"
      type: 'GET'
      success: (data) ->
        return data
    )

  fetchCriteria: (framework_id, programId) ->
    return $.ajax(
      type: 'GET'
      url: "/framework/#{framework_id}/criteria?program_id=#{programId}"
      success: (data) ->
        return data
    )

  fetchFrameworkCriteriumId: (framework_id, criterium_id) ->
    return $.ajax(
      type: 'GET'
      url: "/framework-criteria/#{framework_id}/#{criterium_id}"
      data:
        framework_id: framework_id
        criterium_id: criterium_id
      success: (id)->
        return id
    )

  fetchAssessment: (assessmentId) ->
    return $.ajax(
      url: "/assessments/#{assessmentId}?programId=#{localStorage.getItem('programId')}"
      type: 'GET'
      success: (data) ->
        return data
    )

  updateAssessment: (assessmentId, assessment) =>
    return $.ajax
      url: "/assessments/#{assessmentId}"
      type: 'PUT'
      data: assessment
      success: (response) ->
        return response
      error: (error) ->
        return error

  deleteAssessment: (assessmentId) =>
    return $.ajax
      url: "/assessments/#{assessmentId}"
      type: 'DELETE'
      success: (response) ->
        return response
      error: (error) ->
        return error