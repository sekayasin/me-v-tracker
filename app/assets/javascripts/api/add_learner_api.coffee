class AddLearner.API

  getProgramDlcStack: (programId) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/programs/#{programId}/dlc-stack"
        type: 'GET'
        success: (dlcStacks) ->
          resolve dlcStacks
        error: (error) ->
          reject error
    )

  saveLearnersData: (learnerData) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: '/learners/add'
        type: 'POST'
        data: learnerData
        cache: false
        processData: false
        contentType: false
        success: (data) ->
          resolve data
        error: (error) -> 
          reject error
    )

  checkProgramExists: (programId, city, programCycle) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/programs/#{programId}/program-status"
        type: 'GET'
        data: {
          city: city,
          cycle: programCycle
        }
        success: (existingProgram) ->
          resolve existingProgram
        error: (error) -> 
          reject error
    )

  getCountryCities: (country) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/centers?country=#{country}"
        type: 'GET'
        success: (cities) ->
          resolve cities
        error: (error) ->
          reject error
    )

  getCityLatestCycle: (center) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/cycle?center=#{center}"
        type: 'GET'
        success: (cycle) ->
          resolve cycle
        error: (error) ->
          reject error
    )
