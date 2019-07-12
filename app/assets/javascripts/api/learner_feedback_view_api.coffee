class LearnerFeedbackView.API
  fetchFeedback: (phase_id, assessment_id, afterFeedbackFetch) =>
    request = $.ajax(
      url: "/feedback/#{phase_id}/#{assessment_id}",
      type: 'GET',
      success: (data) ->
        afterFeedbackFetch(data)
    )

  submitReflection: (comment, feedbackId, afterSubmit) =>
    return $.ajax(
      type: 'POST'
      url: "/reflections"
      data: JSON.stringify({'comment' : comment, 'feedback_id': feedbackId})
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'
      success: (data) ->
        afterSubmit(data)
    )

  fetchReflection: (feedbackId, afterFetch) =>
    return $.ajax(
      type: 'GET'
      url: "/reflections?feedback_id=#{feedbackId}"
      success: (data) ->
        afterFetch(data)
    )

  updateReflection: (feedbackId, comment, afterUpdate) =>
    return $.ajax(
      type: 'PUT'
      url: "/reflections?feedback_id=#{feedbackId}"
      data: {'comment' : comment}
      success: (data) ->
        afterUpdate(data)
    )
