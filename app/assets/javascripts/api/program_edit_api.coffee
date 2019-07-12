class ProgramEdit.API
  constructor: ->

  getProgramDetails: (programId, afterFetch) =>
    return $.ajax(
      url: "/programs/#{programId}/edit-details"
      type: "GET"
      success: (details) ->
        afterFetch details
    )

  submitProgramDetails: (programId, programDetails, afterSubmit) =>
    return $.ajax(
      url: "/programs/#{programId}/update"
      type: "PUT",
      data: { details: JSON.stringify(programDetails) }
      success: (response) ->
        afterSubmit response
    )
