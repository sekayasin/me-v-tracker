class ProgramFeedbackChart.UI
  constructor: ->
    @dashboardUI = new Dashboard.UI()
    @chartUI = new ChartJs.UI()
    @chartIds = ['vof-usability', 'bootcamp-usability']
    @programId = localStorage.getItem('programId')
    @centerDropdown = $('#program-feedback-center-dropdown')
    @cycleDropdown = $('#program-feedback-cycle-dropdown')

  onPanelActive: (getProgramFeedback)->
    $('#program-feedback-tab').on 'click', =>
      @renderCharts(
        getProgramFeedback,
        @centerDropdown.val(),
        @cycleDropdown.val()
      )

  populateDropdowns: (fetchProgramFeedbackCenters, getProgramFeedback) =>
    fetchProgramFeedbackCenters(@programId).then(
      (centers) =>
        if Object.keys(centers).length > 0
          @initDropdowns centers

        @centerDropdown.on 'selectmenuchange', (event) =>
          @addCycles(centers[event.target.value])
          @renderCharts(
            getProgramFeedback,
            @centerDropdown.val(),
            @cycleDropdown.val()
          )

        @cycleDropdown.on 'selectmenuchange', (event) =>
          @renderCharts(
            getProgramFeedback,
            @centerDropdown.val(),
            @cycleDropdown.val()
          )
    )

  renderCharts: (getProgramFeedback, center, cycle) =>
    self = @
    if center && cycle
      getProgramFeedback(@programId, center, cycle).then(
        (NPSDataArray) ->
          $('#program-feedback-content-grid').empty()

          for NPSData in NPSDataArray
            titleSlug = NPSData.title.replace /\s/g, '-'
            chartCxId = titleSlug + "-ChartContainer"
            canvasId = titleSlug + "-Chart"
            legendCxId = titleSlug + "-Legend"
            percentages = self.getPercentagesFromTotals(NPSData.nps_totals)

            self.addNPSCanvas(NPSData.title, NPSData.description, titleSlug, chartCxId, canvasId, legendCxId)
            self.dashboardUI.redrawChart(titleSlug + "-Chart", 182)
            self.usabilityNPSChart('VOF NPS', canvasId, legendCxId, NPSData.nps_totals, percentages)
      )

  addNPSCanvas: (title, description, cxId, chartCxId, canvasId, legendCxId) =>
    canvas =
      "<div class='mdl-cell mdl-cell--6-col mdl-cell--8-col-tablet mdl-cell--4-col-phone chart-cell'>
      <div class='mdl-card allow-overflow' id=#{cxId}>
        <div class='mdl-card__supporting-text card-title'>
          <span class='title-text pull-left'>#{title}</span>
          <div class='title-icon pull-left' id='#{canvasId}-icon'>
            <i class='material-icons md-18 md-dark pull-left'>help_outline</i>
          </div>
          <div class='mdl-tooltip mdl-tooltip--top' data-mdl-for='#{canvasId}-icon'>
            #{description}
          </div>
        </div>
        <div class='piechart-wrapper'>
          <div id=#{chartCxId} class='canvas-wrapper pull-left'>
            <canvas height='182px' id=#{canvasId}></canvas>
          </div>
          <div class='legends-wrapper pull-right'>
            <div class='legends-container' id=#{legendCxId}></div>
          </div>
        </div>
      </div>
    </div>"
    $('#program-feedback-content-grid').append canvas
    componentHandler.upgradeDom();

  usabilityNPSChart:(chartName, canvasId, legendsContainerID, totals, percentages) ->
    labels = ["Promoters", "Passives", "Detractors"]
    rotation = 0
    colors = ["#4BABAF", "#FFAF30","#ff3333"]
    chart = @chartUI.pieChart(chartName, canvasId, labels, percentages, colors, rotation, totals)
    $("##{legendsContainerID}").html(chart.generateLegend())

  getPercentagesFromTotals: (totals) ->
    sum = totals.reduce (a, b) -> a + b
    totals.map (total) -> (total/sum * 100).toFixed(1)

  createOption: (text, value) ->
    "<option value=#{value}>#{text}</option>"

  addCenter: (center) =>
    @centerDropdown.append(@createOption center, center)

  addCycles: (cycles) =>
    cycleOptions = ""
    cycleOptions += @createOption cycle, cycle for cycle in cycles
    @cycleDropdown.html ""
    @cycleDropdown.append cycleOptions
    @cycleDropdown.selectmenu("refresh")

  initDropdowns: (centers) =>
    @addCenter center for center, cycles of centers
    @centerDropdown.selectmenu("refresh")

    initCycleOptions = ""
    initCycleOptions += @createOption cycle, cycle for cycle in centers[@centerDropdown.val()]
    @cycleDropdown.append initCycleOptions
    @cycleDropdown.selectmenu("refresh")
