class HolisticPerformanceHistory.Api
  getScoresHistory: (learnerId) ->
    learnerId = learnerId or location.pathname.split('/')[3]
    request = $.ajax(
      url: "/learners/#{learnerId}/holistic-average"
      type: 'get'
      success: (data) ->
        return data
    )
    return request

  updateHolisticEvaluation: (holisticEvaluation, afterUpdate, learnerProgramId) ->
    $.ajax
      url: "/learners/#{learnerProgramId}/holistic-evaluations"
      type: 'PUT'
      data: { holistic_evaluation: holisticEvaluation }
      success: (data) ->
        afterUpdate(data)
      error: (error) ->
        afterUpdate(error)
