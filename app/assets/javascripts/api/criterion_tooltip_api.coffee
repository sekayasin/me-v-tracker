class CriterionTooltip.API
  fetchHolisticCriteriaInfo: ->
    programId = localStorage.getItem('programId')
    return $.ajax(
      url: "/learners/#{programId}/holistic-criteria-info"
      type: 'GET'
      success: (data) ->
        return data
    )
