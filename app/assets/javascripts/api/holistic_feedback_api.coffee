class HolisticFeedback.API
  saveHolisticFeedback: (holisticFeedback) ->
    learnerId = location.pathname.split('/')[2]
    learnerProgramId = location.pathname.split('/')[3]
    return $.ajax(
      type: 'POST'
      url: "/learners/#{learnerId}/#{learnerProgramId}/holistic-feedback"
      data: { holistic_feedback: holisticFeedback }
    )
