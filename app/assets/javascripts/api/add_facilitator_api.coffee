class AddFacilitator.API
  getCities: (country) =>
    new Promise((resolve, reject) -> 
      $.ajax
        url: "/centers?country=#{country}"
        type: 'GET'
        success: (cities) ->
          resolve  cities
        error: (error) ->
          reject error
    )

  getLearners: (country, center_name) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/centers/learners?country=#{country}&name=#{center_name}"
        type: 'GET'
        success: (data) ->
          resolve data
        error: (error) ->
          reject error
    )

  updateLearnerLfa: (updateData) =>
    new Promise((resolve, reject) ->
      $.ajax
        url: "/update_learner_lfa"
        type: 'PUT'
        data: updateData
        success: (data) ->
          resolve data
        error: (error) ->
          reject error
    )

