class ProgramMetricsChart.UI
  constructor: ->
    @dashboardUI = new Dashboard.UI()
    @chartUI = new ChartJs.UI()
    @programId = localStorage.getItem('programId')
    @programMetricsData = null
    @programMetricsWeekOneData = {}
    @export = new Export.UI()
    @chartIds = ['center-per-cycle', 'historical-center', 'lfa-to-learner',
      'perceived-readiness-across-genders', 'program-outcome-week-one',
      'program-outcome-week-two', 'learners-dispersion', 'page-summary']
    @loaderUI = new Loader.UI()

  getChartMetrics: (fetchProgramMetricsData) ->
    self = @
    startDate = self.getDates().startDate
    endDate = self.getDates().endDate
    fetchProgramMetricsData(startDate, endDate).then (data) ->
        self.programMetricsData = data
  
  loadCharts: (fetchProgramMetricsData) ->
    self = @
    self.loaderUI.show()
    self.getChartMetrics(fetchProgramMetricsData).then () ->
      self.visualizeDataCharts()

  visualizeDataCharts: ->
    self = @
    Chart.defaults.global.defaultFontFamily = "DINPro-Regular"
    @averagePerceivedReadinessForCentersChart()
    @historicalCenterAndGenderDistributionChart()
    @lfaToLearnerRatioChart()
    @perceivedReadinessInBootcampAcrossGenders()
    @programOutcomeMetricsChart(
      'programOutcomeMetricsWeekOneChart',
      'programOutcomeMetricsWeekOneLegends',
      'WeekOne'
    )

    @programOutcomeMetricsChart(
      'programOutcomeMetricsWeekTwoChart',
      'programOutcomeMetricsWeekTwoLegends',
      'WeeKTwo'
    )

  averagePerceivedReadinessForCentersChart: =>
    if @programMetricsData
      readinessDataset = @programMetricsData.perceived_readiness_percentages
      canvasId = 'averagePerceivedReadinessinBootcampAcrossCentersChart'
      chartName = 'averagePerceivedReadinessAcrossCenters'

      data = {
        datasets: [
          {
            label: 'Wk 1 Ready > Wk 2 Ready',
            data: readinessDataset.week_2_ready,
            backgroundColor: '#3459db'
          },
          {
            label: 'Wk 1 Ready > Wk 2 Not Ready',
            data: readinessDataset.week_2_not_ready,
            backgroundColor: '#ff3333'
          },
          {
            label: 'Wk 1 Not Ready',
            data: readinessDataset.week_1_not_ready,
            backgroundColor: '#ffaf30'
          }
        ],
        actualData: {
          firstLabel: readinessDataset.week_2_ready_data,
          secondLabel: readinessDataset.week_2_not_ready_data,
          thirdLabel: readinessDataset.week_1_not_ready_data
        }
      }

      labels = readinessDataset.location

      chart = @chartUI.horizontalBar(chartName, canvasId, data, labels)

  learnersDispersionData: ->
    self = @
    dataset = self.programMetricsData.learners_dispersion_data
    centerColors = {
      kampala: '#FFAF30',
      nairobi: '#4BABAF',
      lagos: '#3359DB',
      kigali: '#638CA6'
    } 
    dataset.colors = []
    for center in dataset.centers
      color = centerColors[center.toLowerCase()]
      dataset.colors.push(color || '#999999')
    dataset
    
  learnersDispersionChart: ->
    self = @
    if self.programMetricsData
      dataset = self.learnersDispersionData()
      chartName = 'learnersDispersion'
      canvasId = 'learnersDispersionChart'
      labels = dataset.centers
      data = dataset.percentages
      totals = dataset.totals
      colors = dataset.colors
      rotation = 0
      chart = @chartUI.pieChart(chartName, canvasId, labels, data, colors, rotation, totals)
      $('#learnersDispersionLegends').html(chart.generateLegend())

  genderDistributionData: ->
    self = @
    self.programMetricsData.gender_distribution_data

  historicalCenterAndGenderDistributionChart:->
    self = @
    if self.programMetricsData
      genderDataset = self.genderDistributionData()
      canvasId = 'historicalCenterAndGenderDistributionChart'
      chartName = 'horizontalCenterAndGenderDistribution'

      data = {
        datasets: [
          {
            label: 'male',
            data: genderDataset[3],
            backgroundColor: '#3359DB',
          },
          {
            label: 'female',
            data: genderDataset[4],
            backgroundColor: '#FFAF30',
          }
        ],
        actualData: {
          firstLabel: genderDataset[0],
          secondLabel: genderDataset[1],
        }
      }

      labels = genderDataset[2]

      chart = @chartUI.horizontalBar(chartName, canvasId, data, labels)

  lfaToLearnerRatioChart:->
    self = @
    week_one_percentages = []
    week_two_percentages = []
    first_label_data = []
    second_label_data = []

    if @programMetricsData
      dataset = self.programMetricsData.lfa_to_learner_ratio
      percentages = self.programMetricsData.lfa_to_learner_ratio.percentages
      first_label_data.push(
        dataset[0],
        dataset[2]
        )
      second_label_data.push(
        dataset[1], 
        dataset[3]
        )
      week_one_percentages.push(
        dataset[4][0], 
        dataset[4][2]
        )
      week_two_percentages.push(
        dataset[4][1],
        dataset[4][3]
      )

    canvasId = 'lfaToLearnerRatioChart'
    chartName = 'lfaToLearnerRatio'
    data = {
      datasets: [
        {
          label: 'Week 1',
          data: week_one_percentages,
          backgroundColor: '#3359DB',
        },
        {
          label: 'Week 2',
          data: week_two_percentages,
          backgroundColor: '#FFAF30',
        }
      ],
      actualData: {
        firstLabel: first_label_data,
        secondLabel: second_label_data,
      }
    }
    labels = ['Week 1', 'Week 2']

    chart = @chartUI.horizontalBar(chartName, canvasId, data, labels)

  perceivedReadinessPercentagesGender:->
    self = @
    self.programMetricsData.perceived_readiness_genders

  perceivedReadinessInBootcampAcrossGenders:->
    self = @
    if self.programMetricsData
      dataSet = self.perceivedReadinessPercentagesGender()
      canvasId = 'averagePerceivedReadinessAcrossGendersChart'
      chartName = 'horizontalPerceivedReadinessAcrossGenders'
      data = {
        datasets: [
          {
            label: 'Wk 1 Ready > Wk 2 Ready',
            data: [dataSet.wk2_ready_male_pc, dataSet.wk2_ready_female_pc],
            backgroundColor: '#3459db',
          },
          {
            label: 'Wk 1 Ready > Wk 2 Not Ready',
            data: [dataSet.wk2_not_ready_male_pc, dataSet.wk2_not_ready_female_pc],
            backgroundColor: '#ff3333',
          },
          {
            label: 'Wk 1 Not Ready',
            data: [dataSet.wk1_not_ready_male_pc, dataSet.wk1_not_ready_female_pc],
            backgroundColor: '#ffaf30',
          }
        ],
        actualData: {
          firstLabel: [dataSet.wk2_ready_male, dataSet.wk2_ready_female],
          secondLabel: [dataSet.wk2_not_ready_male, dataSet.wk2_not_ready_female],
          thirdLabel: [dataSet.wk1_not_ready_male, dataSet.wk1_not_ready_female]
        }
      }
      labels = ['Male', 'Female']
      chart = @chartUI.horizontalBar(chartName, canvasId, data, labels)


  programOutcomeMetricsChart: (
    canvasId, legendsContainerId, phase, totals=[], labels=[], percentages=[]) ->
    self = @
    colorsMapping = {
      'Advanced': '#3359DF',
      'Accepted': '#3359DF'
      'Level Up': '#4BABAF',
      'Dropped Out': '#999999',
      'Try Again': '#FFAF30',
      'Rejected': '#7E0AED',
      'No Show': '#000000'
    }

    if phase is 'WeekOne'
      weekMetrics = self.programMetricsData.phase_one_metrics
      labels = weekMetrics.decisions
      percentages = weekMetrics.percentages
      colors = []
      totals = weekMetrics.totals
    else
      if self.programMetricsData
        weekMetrics = self.programMetricsData.phase_two_metrics
        labels = weekMetrics.decisions
        percentages = weekMetrics.percentages
        colors = []
        totals = weekMetrics.totals
      else
        return

    for decision, color of weekMetrics.decisions
      colors.push(colorsMapping[color])

      rotation = 0

      chartName = 'programHealthMetrics'
      chart = @chartUI.pieChart(
        chartName, canvasId, labels, percentages, colors, rotation, totals
      )
      $("##{legendsContainerId}").html(chart.generateLegend())


  lfaEvaluationVarianceChart: ->
    canvasId = 'programMetricsLfaEvaluationVarianceChart'
    actual = [50]
    target = [65]
    @dashboardUI.lfaEvaluationVarianceData(canvasId, actual, target)

  refreshCanvas: ->
    self = @

    historicalCentersCount = 0
    perceivedReadinessCentersCount = 0
    if self.programMetricsData
      historicalCentersCount =
        self.programMetricsData.gender_distribution_data[0].length
      perceivedReadinessCentersCount =
        self.programMetricsData.perceived_readiness_percentages.location.length

    self.dashboardUI.redrawChart("learnersDispersionChart", 162)
    self.dashboardUI.redrawChart("programOutcomeMetricsWeekOneChart", 162)
    self.dashboardUI.redrawChart("programOutcomeMetricsWeekTwoChart", 162)
    self.dashboardUI.redrawChart(
      "historicalCenterAndGenderDistributionChart",
      80 * historicalCentersCount
    )
    self.dashboardUI.redrawChart("lfaToLearnerRatioChart", 200)
    self.dashboardUI.redrawChart("
      averagePerceivedReadinessinBootcampAcrossCentersChart",
      80 * perceivedReadinessCentersCount
    )
    self.dashboardUI.redrawChart("averagePerceivedReadinessAcrossGendersChart", 250)

  reRenderCharts: ->
    self = @
    self.learnersDispersionChart()
    self.programOutcomeMetricsChart(
      'programOutcomeMetricsWeekOneChart',
      'programOutcomeMetricsWeekOneLegends',
      'WeekOne'
    )
    self.programOutcomeMetricsChart(
      'programOutcomeMetricsWeekTwoChart',
      'programOutcomeMetricsWeekTwoLegends',
      'WeekTwo'
    )
    self.perceivedReadinessInBootcampAcrossGenders()
    self.averagePerceivedReadinessForCentersChart()
    self.historicalCenterAndGenderDistributionChart()
    self.lfaToLearnerRatioChart()
    self.loaderUI.hide()

  handleResizing: ->
    self = @
    $(window).resize ->
      if (!$('#program-metrics-panel').hasClass('is-active'))
        return

      self.refreshCanvas()
      self.reRenderCharts()
      return

  getDateValue: (target) ->
    $(target).val()

  getDates: ->
    self = @
    {
      startDate: self.getDateValue(".select-start-date")
      endDate: self.getDateValue(".select-end-date")
    }

  populateCyclesPerCity: (data) ->
    $("div#center-per-cycle").empty()
    for city, cycle of data
      $("div#center-per-cycle").css("background-color", "#F1F1F1")
      $("div#center-per-cycle")
      .append(
        "<div class='center'>
          #{city}&nbsp;&nbsp;<span class='cycle'>#{cycle}</span>
        </div>"
      )
      $("div#center-per-cycle .center").css("background-color", "#FFFFFF")

  toastMessage: (message, status) =>
    self = @
    $(".toast").messageToast.start(message, status)

  handleDateSelection: (fetchProgramMetricsData) ->
    self = @
    startDate = self.getDates().startDate
    endDate = self.getDates().endDate

    fetchProgramMetricsData(startDate, endDate).then (programDetails) ->
      self.populateCyclesPerCity(programDetails.cycles_per_centre)
      $(".select-start-date").val programDetails.min_max_dates[0]
      $(".select-end-date").val programDetails.min_max_dates[3]

      $('.select-start-date').datepicker 'option',
        minDate: programDetails.min_max_dates[0],
        maxDate: programDetails.min_max_dates[1],
        changeYear: true,
        changeMonth: true,
        showButtonPanel: false,
        onClose: (selectedDate) ->
          splitDate = selectedDate.split('-')
          selectedDate = new Date(splitDate[0], Number(splitDate[1]) - 1, Number(splitDate[2]) + 1)
          $('.select-end-date').datepicker("option", "minDate", selectedDate)

      $('.select-end-date').datepicker 'option',
        minDate: programDetails.min_max_dates[0],
        maxDate: programDetails.min_max_dates[1],
        changeYear: true,
        changeMonth: true,
        showButtonPanel: false,
        onClose: (selectedDate) ->
          splitDate = selectedDate.split('-')
          selectedDate = new Date(splitDate[0], Number(splitDate[1]) - 1, Number(splitDate[2] - 1))
          $('.select-start-date').datepicker("option", "maxDate", selectedDate)

        # update tab data
        self.programMetricsData = programDetails
        self.programMetricsWeekOneData = self.programMetricsData

        # Re-render charts when tab data is loaded
        self.refreshCanvas()
        self.reRenderCharts()

    $('.select-start-date').datepicker
      dateFormat: 'yy-mm-dd'
      onSelect: ->
        $(this).trigger 'change'

    $('.select-end-date').datepicker
      dateFormat: 'yy-mm-dd'
      onSelect: ->
        $(this).trigger 'change'
        startDate = self.getDates().startDate
        endDate = self.getDates().endDate

        fetchProgramMetricsData(startDate, endDate).then (data) ->
          $("span#cycles-per-centre").html(" ")
          self.populateCyclesPerCity(data.cycles_per_centre)
          if Object.keys(data.cycles_per_centre).length == 0
            self.toastMessage('There are no cycles within the selected dates', 'error')
            $(".select-start-date").val data.min_max_dates[0]
            $(".select-end-date").val data.min_max_dates[3]

            fetchProgramMetricsData(data.min_max_dates[0], data.min_max_dates[3]).then (data) ->
              self.populateCyclesPerCity(data.cycles_per_centre)
              self.programMetricsData = data
              self.programMetricsWeekOneData = self.programMetricsData
              self.refreshCanvas()
              self.reRenderCharts()

          # update tab data
          self.programMetricsData = data
          self.programMetricsWeekOneData = self.programMetricsData

          # Re-render charts on date change
          self.refreshCanvas()
          self.reRenderCharts()

  getJPGExport: ->
    self = @
    self.export.getJPGExport(@chartIds, "program_metrics", @loaderUI)

  getPdfExport: ->
    self  = @
    self.export.getPdfExport(@chartIds, "program_metrics", @loaderUI)

  downloadReport: ->
    self = @
    $("#get-export li").on 'click', (event) ->
      event.preventDefault();
      activeTabId = $('.switching-tabs .is-active').attr('id')
      exportFormat = $(this).data('value')
      if activeTabId != 'program-metrics-tab'
        return
      if exportFormat == 'pdf'
        self.getPdfExport(@chartIds, "program_metrics", @loaderUI)
      else if exportFormat == 'jpg'
        self.getJPGExport(@chartIds, "program_metrics", @loaderUI)
      else if exportFormat == 'csv'
        { startDate, endDate } = self.getDates()
        reportType = 'program_metrics'
        url = """
          #{window.location.protocol}//#{window.location.host}/analytics/export?
          format=#{exportFormat}&start_date=#{startDate}&end_date=#{endDate}&report_type=#{reportType}
          """
        window.location.href = url
