class LearnersProfile.API
  updatePersonalDetails: (personalDetails) ->
    return $.ajax
      url: '/learners/personal_details/update',
      type: 'PUT',
      contentType: false,
      cache: false,
      data: personalDetails
      processData: false,
      success: (response) ->
        return response
      error: (error) ->
        return error
    
