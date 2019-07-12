class CycleMetricsChart.UI
  constructor: ->
    @dashboardUI = new Dashboard.UI()
    @chartUI = new ChartJs.UI()
    @chartData = {}
    @helpers = new Helpers.UI()
    @export = new Export.UI()
    @loaderUI = new Loader.UI()
    @chartIds= ['performance-quality', 'output-quality', 'learner-quantity', 'cycle_center_program-outcome-week-one',
      'cycle_center_program-outcome-week-two', 'lfa-learner-ratio', 'gender-distribtion', 'page-summary']

  getValueById: (id) ->
    return @helpers.getValueById(id)

  getChartMetrics: (center, fetchCenterCyclesData) =>
    self = @
    if @chartData and @chartData[center]
      return

    fetchCenterCyclesData(center).then (data) ->
      self.chartData[center] = data

  populateCenterCycleDropdown: (cycles) ->
    if (!Array.isArray(cycles))
      return

    $('#cycle-dropdown').empty()
    cycles.map (cycle) ->
      $('#cycle-dropdown').append("<option value='#{cycle}'>#{cycle}</option>")
    $('#cycle-dropdown').selectmenu('refresh')

  centerDropdownOnChange: (fetchCenterCyclesData) ->
    self = @

    $("#center-dropdown").on 'selectmenuchange',  ->
      $('#cycle-dropdown').selectmenu('refresh')
      self.dashboardUI.redrawChart('learnerQuantityChart', 230)
      self.dashboardUI.redrawChart('performanceQualityOverTimeChart', 230)
      self.dashboardUI.redrawChart('outputQualityOverTimeChart', 230)
      self.dashboardUI.redrawChart("cycleGenderDistributionChart", 162)
      self.dashboardUI.redrawChart('cycleProgramOutcomeMetricsChartWeekOne', 162)
      self.dashboardUI.redrawChart("cycleLfaToLearnerRatioChart", 230)
      self.visualizeDataCharts(fetchCenterCyclesData)

  onPanelActive: (fetchCenterCyclesData, getChartMetrics) ->
    self = @
    $('#cycle-metrics-tab').on 'click', ->
      self.loadCharts(fetchCenterCyclesData, self.getChartMetrics)

  initializeCharts: ->
    center = @getValueById("#center-dropdown")

    @populateCenterCycleDropdown(@chartData[center].cycles)

    @renderCharts()

  renderCharts: ->
    center = @getValueById("#center-dropdown")

    @dashboardUI.redrawChart("cycleProgramOutcomeMetricsChartWeekOne", 162)
    @programOutcomeMetricsChart(
      'cycleProgramOutcomeMetricsChartWeekOne',
      'cycleProgramOutcomeMetricsWeekOneLegends',
      'weekOne',
      @chartData[center]
    )

    @dashboardUI.redrawChart("cycleProgramOutcomeMetricsChartWeekTwo", 162)
    @programOutcomeMetricsChart(
      'cycleProgramOutcomeMetricsChartWeekTwo',
      'cycleProgramOutcomeMetricsWeekTwoLegends',
      'weekTwo',
      @chartData[center]
    )

    @dashboardUI.redrawChart("cycleGenderDistributionChart", 162)
    @genderDistributionChart(@chartData[center])
    @lfaToLearnersRatioChart(@chartData[center])
    @learnerQuantityChart(@chartData[center])
    @performanceQualityOverTimeChart(@chartData[center])
    @outputQualityOverTimeChart(@chartData[center])

  loadCharts: (fetchCenterCyclesData, getChartMetrics) ->
    self = @
    center = self.getValueById("#center-dropdown")

    if self.chartData[center]
      self.initializeCharts()
    else
      getChartMetrics(center, fetchCenterCyclesData).then () ->
        self.initializeCharts()

  cycleDropdownOnChange: () ->
    self = @
    $("#cycle-dropdown").on 'selectmenuchange',  ->
      self.renderCycleCharts()

  renderCycleCharts: ->
    self = @
    center = self.getValueById("#center-dropdown")

    self.redrawGenderChart()

    self.dashboardUI.redrawChart("cycleProgramOutcomeMetricsChartWeekOne", 162)
    self.programOutcomeMetricsChart(
      'cycleProgramOutcomeMetricsChartWeekOne',
      'cycleProgramOutcomeMetricsWeekOneLegends',
      'weekOne',
      self.chartData[center]
    )

    self.dashboardUI.redrawChart("cycleProgramOutcomeMetricsChartWeekTwo", 162)
    self.programOutcomeMetricsChart(
      'cycleProgramOutcomeMetricsChartWeekTwo',
      'cycleProgramOutcomeMetricsWeekTwoLegends',
      'weekTwo',
      self.chartData[center]
    )

    self.dashboardUI.redrawChart("cycleLfaToLearnerRatioChart", 230)
    self.lfaToLearnersRatioChart(self.chartData[center])

  genderDropdownOnChange: ->
    self = @
    $("#gender-dropdown").on 'selectmenuchange', ->
      self.redrawGenderChart()

  redrawGenderChart: ->
    self = @
    center = self.getValueById("#center-dropdown")
    self.dashboardUI.redrawChart("cycleGenderDistributionChart", 162)
    self.genderDistributionChart(self.chartData[center])

  visualizeDataCharts: (fetchCenterCyclesData) ->
    Chart.defaults.global.defaultFontFamily = "DINPro-Light"
    self = @

    if $('#cycle-metrics-panel').hasClass('is-active')
      self.loadCharts(fetchCenterCyclesData, self.getChartMetrics)

  outputQualityOverTimeChart: (data) ->
    actual = []  
    target = []
    canvasId = 'outputQualityOverTimeChart'
    chartName = 'outputQualityOverTime'
    Ylabels = data.cycles[0..5].reverse().map (cycle) -> "Cycle #{cycle}"

    for cycle, value of data.performance_and_output_quality
      target.push value.target[1]
      actual.push value.output_average

    datasets = [
      {
        label: 'Actual',
        data: actual
      },
      {
        label: 'Target',
        data: target
      }
    ]

    @chartUI.lineChart(chartName, canvasId, Ylabels, datasets)

  performanceQualityOverTimeChart: (data) ->
    devFrameworkAverage = []
    holisticPerformanceAverage = []
    target = []

    for cycle, value of data.performance_and_output_quality
      devFrameworkAverage.push value['developer_framework_average']
      holisticPerformanceAverage.push value['holistic_performance_average']
      target.push value.target[0]

    canvasId = 'performanceQualityOverTimeChart'
    chartName = 'performanceQualityOverTime'
    Ylabels = data.cycles[0..5].reverse().map (cycle) -> "Cycle #{cycle}"

    datasets = [
      {
        label: 'Dev Framework',
        data: devFrameworkAverage
      },
      {
        label: 'Holistic Performance',
        data: holisticPerformanceAverage
      },
      {
        label: 'Target',
        data: target
      }
    ]

    @chartUI.lineChart(chartName, canvasId, Ylabels, datasets)

  learnerQuantityChart: (data) ->
    chartName = 'learnerQuantity'
    canvasId = 'learnerQuantityChart'

    learnerTotal = []
    learnerMale = []
    learnerFemale = []
    for cycle, value of data.learner_quantity
      learnerTotal.push(value.total)
      learnerMale.push(value.male)
      learnerFemale.push(value.female)

    labels = data.cycles[0..5].reverse().map (cycle) -> "Cycle #{cycle}"

    datasets = [
      {
        label: 'Total '
        data: learnerTotal,
        backgroundColor: '#3359DB',
        borderWidth: 1,
      },
      {
        label: 'Male  '
        data: learnerMale,
        backgroundColor: '#3359DB',
        borderWidth: 1,
      },
      {
        label: 'Female '
        data: learnerFemale,
        backgroundColor: '#3359DB',
        borderWidth: 1,
      }
    ]

    @chartUI.mixedChart(chartName, canvasId, labels, datasets)

  lfaToLearnersRatioChart: (data) ->
    canvasId = 'cycleLfaToLearnerRatioChart'
    chartName = 'lfaToLearnerRatio'
    cycle = @getValueById("#cycle-dropdown")
    dataset = data.lfa_learner_ratio
    percentages = data.lfa_to_learner_percent

    first_label = []
    second_label = []
    week_one_percentages = []
    week_two_percentages = []

    first_label.push(
      dataset.week_one_lfas[cycle], 
      dataset.week_two_lfas[cycle]
    )
    second_label.push(
      dataset.week_one_learners[cycle], 
      dataset.week_two_learners[cycle]
    )
    week_one_percentages.push(
      percentages[cycle].week_one_lfa, 
      percentages[cycle].week_two_lfa
    )
    week_two_percentages.push(
      percentages[cycle].week_one_learner, 
      percentages[cycle].week_two_learner
    )

    data = {
      datasets: [
        {
          label: 'Week 1',
          data: week_one_percentages,
          backgroundColor: '#3359db',
        },
        {
          label: 'Week 2',
          data: week_two_percentages,
          backgroundColor: '#ffaf30',
        }
      ],
      actualData: {
        firstLabel: first_label,
        secondLabel: second_label,
      }
    }
    labels = ['Week 1', 'Week 2']

    chart = @chartUI.horizontalBar(chartName, canvasId, data, labels)

  programOutcomeMetricsChart: (canvasId, legendsContainerId, week, chartData) ->
    self = @
    cycle = @getValueById("#cycle-dropdown")

    if week is 'weekOne'
      weekOneData = chartData.week_one_decisions[cycle]
      programOutcomeData = @weekOneOutcomeData(weekOneData)
    else
      weekTwoData = chartData.week_two_cycle_metrics[cycle]
      programOutcomeData = @weekTwoOutcomeData(weekTwoData)
    labels = programOutcomeData.labels
    percentages = programOutcomeData.percentages
    totals = programOutcomeData.totals
    colors = programOutcomeData.colors
    rotation = 0
    chartName = 'programOutcomeMetrics'
    chart = @chartUI.pieChart(
      chartName, canvasId, labels, percentages, colors, rotation, totals
    )
    $("##{legendsContainerId}").html(chart.generateLegend())

  weekOneOutcomeData: (weekOneData) ->
    totals = []
    percentages = []
    labels = []
    colors = []

    for label of weekOneData
      if weekOneData[label]['total_count'] != 0
        totals.push(Number(weekOneData[label]['total_count']))
        percentages.push(Number(weekOneData[label]['percentage']))
        labels.push(label)
        colors.push(@colorsMapping()[label])

    return {
      totals, labels, percentages, colors
    }

  weekTwoOutcomeData: (weekTwoData) ->
    percentages = []
    colors = []
    totals = []
    total_count =  weekTwoData.totals
    percentagesData =  weekTwoData.percentage
    labels =  weekTwoData.labels
    
    for keys in labels
      percentages.push(percentagesData[keys])
      totals.push(total_count[keys])
      colors.push(@colorsMapping()[keys])

    return {
      totals, labels, percentages, colors
    }
    
  colorsMapping: -> {
      'Advanced': '#3359DF',
      'Accepted': '#3359DF'
      'Level Up': '#4BABAF',
      'Dropped Out': '#999999',
      'Try Again': '#FFAF30',
      'Rejected': '#7E0AED',
      'No Show': '#000000'
    }

  genderDistributionChart: (data) ->
    chartName = 'genderDistribution'
    cycle = @getValueById("#cycle-dropdown")
    param = @getValueById("#gender-dropdown")
    percentages = []
    totals = []

    if cycle == null
      cycle = data.cycles[..].pop()

    if param == "All"
      male = data.gender_distribution[cycle]['male']
      female = data.gender_distribution[cycle]['female']
      total = data.gender_distribution[cycle]['total']
      percentage_male = (male/total)*100
      percentage_female = (female/total)*100
      totals.push(male)
      totals.push(female)
      percentages.push(parseFloat(percentage_male).toFixed(1))
      percentages.push(parseFloat(percentage_female).toFixed(1))
    else
      male = data.gender_distribution[cycle]['num_accepted_males']
      female = data.gender_distribution[cycle]['num_accepted_females']
      total = data.gender_distribution[cycle]['total_accepted']
      percentage_male = (male/total)*100
      percentage_female = (female/total)*100
      totals.push(male)
      totals.push(female)
      percentages.push(parseFloat(percentage_male).toFixed(1))
      percentages.push(parseFloat(percentage_female).toFixed(1))

    labels = ['Male', 'Female']
    rotation = 0
    colors = ["#3359df",  "#ffaf30"]
    canvasId = 'cycleGenderDistributionChart'
    chart = @chartUI.pieChart(chartName, canvasId, labels, percentages, colors, rotation, totals)
    $("#cycleGenderDistributionChartLegends").html(chart.generateLegend())

  handleResizing: ->
    self = @
    center = self.getValueById("#center-dropdown")

    $(window).resize ->
      setTimeout( ->
        if (!$('#cycle-metrics-panel').hasClass('is-active'))
          return

        center = self.getValueById("#center-dropdown")
        self.dashboardUI.redrawChart("performanceQualityOverTimeChart", 190)
        self.performanceQualityOverTimeChart(self.chartData[center])
        self.dashboardUI.redrawChart("outputQualityOverTimeChart", 190)
        self.outputQualityOverTimeChart(self.chartData[center])

        self.dashboardUI.redrawChart("cycleProgramOutcomeMetricsChartWeekOne", 162)
        self.programOutcomeMetricsChart(
            'cycleProgramOutcomeMetricsChartWeekOne',
            'cycleProgramOutcomeMetricsWeekOneLegends',
            'weekOne',
            self.chartData[center]
        )

        self.dashboardUI.redrawChart("cycleProgramOutcomeMetricsChartWeekTwo", 162)
        self.programOutcomeMetricsChart(
            'cycleProgramOutcomeMetricsChartWeekTwo',
            'cycleProgramOutcomeMetricsWeekTwoLegends',
            'weekTwo',
            self.chartData[center]
        )

        self.dashboardUI.redrawChart("cycleLfaToLearnerRatioChart", 230)
        self.lfaToLearnersRatioChart(self.chartData[center])

        self.dashboardUI.redrawChart("cycleGenderDistributionChart", 162)
        self.genderDistributionChart(self.chartData[center])
      , 1000)
    return

  getJPGExport: ->
    self = @
    self.export.getJPGExport(@chartIds, 'cycle_and_center_metrics', @loaderUI)

  getPdfExport: ->
    self = @
    self.export.getPdfExport(@chartIds, 'cycle_and_center_metrics', @loaderUI)

  downloadReport: (programId)->
    self = @
    $("#get-export li").on 'click', (event) ->
      event.preventDefault();
      activeTabId = $('.switching-tabs .is-active').attr('id')
      exportFormat = $(this).data('value')
      if activeTabId != 'cycle-metrics-tab'
        return
      if exportFormat == 'pdf'
        self.getPdfExport(@chartIds, 'cycle_and_center_metrics', @loaderUI)
      else if exportFormat == 'jpg'
        self.getJPGExport(@chartIds, 'cycle_and_center_metrics', @loaderUI)
      else if exportFormat == 'csv'
        center = self.getValueById("#center-dropdown")
        cycle = self.getValueById("#cycle-dropdown")
        reportType = 'cycle_metrics'
        url = """
          #{window.location.protocol}//#{window.location.host}/analytics/export?
          format=#{exportFormat}&report_type=#{reportType}&program_id=#{programId}&cycle=#{cycle}&center=#{center}
          """
        window.location.href = url
