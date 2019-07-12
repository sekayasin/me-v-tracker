class Submissions.API

  fetchLearners: (content_size, page = 1, filters) ->
    return $.ajax(
      url: "/submissions/learners?page=#{page}&size=#{content_size}"
      type: 'GET'
      data: filters
      success: () ->
        $("html, body").animate({ scrollTop: 0 }, "normal")
    )

  fetchPhases: (afterPhasesFetch, learnerProgramId) ->
    return $.ajax(
      url: "/submissions/learner/#{learnerProgramId}"
      type: 'GET'
      success: (data) ->
        afterPhasesFetch(data)
    )

  fetchOutput: (learnerProgramId, phaseId, assessmentId, afterOutputFetch) ->
    return $.ajax(
      url: "/submissions/#{learnerProgramId}/#{phaseId}/#{assessmentId}"
      type: 'GET'
      success: (data) ->
        afterOutputFetch(data)
    )

  getFeedbackMetadata: () ->
    learnerProgramId = pageUrl[2]
    return $.ajax(
      url: "/feedback?learner_program_id=#{learnerProgramId}"
      type: 'GET'
    )

  giveFeedback: (feedback) =>
    return $.ajax(
      url: "/feedback/save"
      type: 'POST'
      data: { details: feedback }
      success: (response) ->
        return response
    )

  fetchFeedbackDetails:(feedback) =>
    return $.ajax(
      url: "/feedback/get-learner-feedback"
      type: 'GET'
      data: { details: feedback }
    )

  fetchReflectionDetails: (feedbackId) =>
    return $.ajax(
      url: "/reflections?feedback_id=#{feedbackId}"
      type: 'GET'
    )

  fetchFilterParams: () ->
    return $.ajax(
      url: "/submission/filter"
      type: 'GET'
      success: (data) ->
        return data
    )

  fetchCycles: (centers) ->
    return $.ajax(
      url: "/submissions/filter/cycles"
      type: 'GET'
      data: centers
      success: (data) ->
        return data
    )

  fetchFacilitators: (lfaParams) ->
    return $.ajax(
      url: "/submissions/filter/facilitators"
      type: 'GET'
      data: lfaParams
      success: (data) ->
        return data
    )
