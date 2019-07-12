class Criteria.API
  updateCriteria: (criteriaId, criteriaDetails) ->
    return $.ajax(
      url: "/criteria/#{criteriaId}/description"
      type: 'PUT'
      data: criteriaDetails
      dataType: 'json'
      success: (data) ->
        return data
    )

  deleteCriterion: (criterionId) ->
    return $.ajax
      url: "/criteria/#{criterionId}"
      type: 'DELETE'
      success: (response) ->
        return response
      error: (error) ->
        return error
