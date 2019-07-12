class CriterionTooltip.UI
  constructor: ->
    @modal = new Modal.App("#criterion-tooltip-modal", 545, 545, 650, 650)
    @tooltipsInfo = {}

  openCriterionTooltipModal: (criterionTooltipIds) =>
    self = @
    $(criterionTooltipIds.join(", ")).click ->
      tooltipContent = self.tooltipsInfo[this.id]
      self.populateCriterionTooltipInfo(tooltipContent)
      window.scrollTo(0, 0)
      self.modal.open()
      $("body").css("overflow-y", "hidden")
      $("#holistic-performance-evaluation").css("display", "none")

  closeCriterionTooltipModal: =>
    self = @
    $('#close-button').click ->
      self.modal.close()
      $("body").css("overflow", "auto")
      $("#holistic-performance-evaluation").css("display", "block")

  initializeCriterionTooltipModal: (criteriaInfo) =>
    if criteriaInfo && criteriaInfo.criteria?
      criterionTooltipIds = criteriaInfo.criteria.map (criterion) ->
        "#criterion-".concat(criterion.id)

      for criterion in criteriaInfo.criteria
        @setCriterionTooltipsInfo(criterion, criteriaInfo.metrics)

      @openCriterionTooltipModal(criterionTooltipIds)
      @closeCriterionTooltipModal()

  setCriterionTooltipsInfo: (criterion, metrics) =>
    self = @
    criterionTooltipMetrics = 
      self.getCriterionTooltipMetrics(criterion.id, metrics)

    self.tooltipsInfo["criterion-".concat(criterion.id)] = {
      "name": self.formatTooltipInfo(criterion.name),
      "context_metric": self.formatTooltipInfo(criterion.context),
      "description": self.formatTooltipInfo(criterion.description),
      "very_unsatisfied": self.formatTooltipInfo(criterionTooltipMetrics['-2']),
      "unsatisfied": self.formatTooltipInfo(criterionTooltipMetrics['-1']),
      "neutral": self.formatTooltipInfo(criterionTooltipMetrics['0']),
      "satisfied": self.formatTooltipInfo(criterionTooltipMetrics['1']),
      "very_satisfied": self.formatTooltipInfo(criterionTooltipMetrics['2'])
    }

  formatTooltipInfo: (text) =>
    if !text
      text = "N/A"
    
    return text

  getCriterionTooltipMetrics: (criterionId, metrics) =>
    self = @
    criterionTooltipMetrics = {}

    for metric in metrics
      if criterionId == metric.criteria_id
        criterionTooltipMetrics[metric.value] =
          self.formatTooltipInfo(metric.description)

    return criterionTooltipMetrics

  populateCriterionTooltipInfo: (tooltipContent) ->
    $('#criterion-title').html(tooltipContent['name'])
    $('#criterion-context-metric').html(tooltipContent['context_metric'])
    $('#criterion-description').html(tooltipContent['description'])
    $('#criterion-very-unsatisfied').html(tooltipContent['very_unsatisfied'])
    $('#criterion-unsatisfied').html(tooltipContent['unsatisfied'])
    $('#criterion-neutral').html(tooltipContent['neutral'])
    $('#criterion-satisfied').html(tooltipContent['satisfied'])
    $('#criterion-very-satisfied').html(tooltipContent['very_satisfied'])
