class Accordion.App
  constructor: ->
    @ui = new Accordion.UI()
  
  start: =>
    @ui.initAccordion()
