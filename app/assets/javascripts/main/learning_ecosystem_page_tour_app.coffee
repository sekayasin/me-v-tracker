class LearningEcosystemPageTour.App
  constructor: ->
    @api = new Tour.API()
    @ui = new LearningEcosystemPageTour.UI(@api)

  start: ->
    @ui.initLearningEcosystemPageTour()
    