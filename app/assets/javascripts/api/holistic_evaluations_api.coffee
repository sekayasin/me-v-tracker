class HolisticEvaluations.API

  saveHolisticEvaluation: (holisticEvaluation) ->
    learnerId = location.pathname.split('/')[2]
    learnerProgramId = location.pathname.split('/')[3]
    request = $.ajax(
      url: "/learners/#{learnerId}/#{learnerProgramId}/holistic-evaluations"
      type: 'POST'
      data: { holistic_evaluation: holisticEvaluation }
    )
    return request

  getHolisticAverages:  =>
    learnerId = location.pathname.split('/')[3]
    request = $.ajax(
      url: "/learners/#{learnerId}/holistic-criteria-average",
      type: "GET"
    )

    return request

  getEvaluationEligibility: =>
    learnerProgramId = location.pathname.split('/')[3]
    return $.ajax(
      url: "/learners/#{learnerProgramId}/evaluation-eligibility",
      type: "GET"
    )
