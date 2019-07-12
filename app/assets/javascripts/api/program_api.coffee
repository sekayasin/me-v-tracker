class Program.API
  fetch: (programId) ->
    return $.ajax(
      url: "/programs/#{programId}.json"
      type: 'GET'
      success: (data) ->
        return data
    )

  createProgram: (programDetails) ->
    return $.ajax(
      url: "/programs"
      type: 'POST'
      data: program: programDetails
      success: (data) ->
        return data
    )
  
  getAllPrograms: (size, page) ->
    return $.ajax(
      url: "/programs/#{size}/#{page}.json"
      type: "GET"
      success: (allPrograms) ->
        return allPrograms
    )
