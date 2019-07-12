class LearnerScore.API
  getAssessments: (url) =>
    return $.ajax
      type: 'GET'
      url: url
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'

  sendScoreData: (scoreData) =>
    return $.ajax
        url: 'scores/new'
        type: 'POST'
        contentType: 'application/json;charset=utf-8'
        data: JSON.stringify({ 'scores': scoreData })

  getSubmittedScores: (url) =>
    return $.ajax
      type: 'GET'
      url: "completed_assessments"
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'

  getOutputMetrics: (assessmentId) =>
    return $.ajax
      type: 'GET'
      url: "/metrics/#{assessmentId}"
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'

  getVerifiedOutputs: (url) =>
    return $.ajax
      type: 'GET'
      url: url
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'
