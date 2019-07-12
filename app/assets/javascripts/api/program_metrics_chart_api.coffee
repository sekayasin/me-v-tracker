class ProgramMetricsChart.API
  getProgramMetrics: (programId, startDate, endDate) ->
    return $.ajax(
      url: "/programs/#{programId}/program-metrics?start_date=#{startDate}&end_date=#{endDate}"
      type: "GET"
      success: (data) ->
        return data
    )
