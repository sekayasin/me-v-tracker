class LearnersDashboard.API
  setDecisionStatus: (decisionData, learnerProgramId) ->
    new Promise((resolve, reject) ->
      $.ajax
        url: "/learners/decision-status/#{learnerProgramId}"
        type: 'PUT'
        data: decisionData
        success: (response) ->
          resolve response
        error: (error) -> 
          reject error
    )

  saveDecision: (decisions) ->
    new Promise((resolve, reject) ->
      $.ajax
        url: "/decision/add"
        type: 'POST'
        data: decisions
        success: (response) ->
          resolve response
        error: (error) -> 
          reject error
    )

  getDecisionReason: (status) ->
    new Promise((resolve, reject) ->
      $.ajax
        url: "/decision/reason/#{status}"
        type: 'GET'
        success: (decisionReasons) ->
          resolve decisionReasons
        error: (error) -> 
          reject error
    )
  