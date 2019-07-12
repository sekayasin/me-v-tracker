class CriterionTooltip.App
  constructor: ->
    @criterionTooltipUI = new CriterionTooltip.UI()
    @criterionTooltipAPI = new CriterionTooltip.API()
    
  start: =>
    self = @
    self.criterionTooltipAPI.fetchHolisticCriteriaInfo()
    .then (data) ->
      self.criterionTooltipUI.initializeCriterionTooltipModal(data)
