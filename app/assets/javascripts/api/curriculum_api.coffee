class Curriculum.API
  fetchCurriculumDetails: (programId) ->
    return $.ajax(
      url: "/curriculum/details?program_id=#{programId}"
      type: 'GET'
      success: (data) ->
        return data
    )

  fetchSearchResults: (query, programId) ->
    return $.ajax(
      url: "/curriculum/details?search=#{query}&program_id=#{programId}"
      type: 'GET'
      success: (data) ->
        return data
    )
