class Slider.App
  constructor: ->
    @ui = new Slider.UI()
   
  start: =>
    @ui.sliderControlListener()
    @ui.animateSlider()
    
