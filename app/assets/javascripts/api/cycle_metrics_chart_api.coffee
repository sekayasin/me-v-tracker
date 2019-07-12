class CycleMetricsChart.API
  fetchCenterCyclesData: (programId, center) ->
    return $.ajax(
      url: "/programs/#{programId}/centers/#{center}/cycles"
      type: 'GET'
      success: (data) ->
        return data
    )
