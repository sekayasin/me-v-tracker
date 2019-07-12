class PersonalFeedback.API
  getFeedbackMetadata: (learnerProgramId) ->
    learnerProgramId = location.pathname.split("/")[3]
    return $.ajax(
      url: "/feedback?learner_program_id=#{learnerProgramId}"
      type: 'GET'
    )

  getAssessmentMetadata: () ->
    phaseId = $('#learner-phase').val()
    return $.ajax(
      url: "/phases/#{phaseId}/assessment"
      type: 'GET'
    )

  createUpdatePersonalFeedback: (details) ->
    return $.ajax(
      url: '/feedback/save'
      type: 'POST'
      data: { details: details }
    )

  getLearnerFeedback: (details) ->
    return $.ajax(
      url: '/feedback/get-learner-feedback'
      type: 'GET'
      data: { details: details }
    )
