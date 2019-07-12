class DecisionHistory.Api
  getDecisionHistory: (learnerId) ->
    request = $.ajax(
      url: "/learners/#{learnerId}/decision-history"
      type: 'get'
      success: (data) ->
        return data
    )
    return request
