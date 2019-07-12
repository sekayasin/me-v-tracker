class Tab.App
  constructor: ->
    @ui = new Tab.UI()

  start: =>
    @ui.initializeTab()
