class Slider.UI
  slideIndex = 0;

  constructor: (@sliderClass = 'slides', @controlClass = 'slider-control') ->
    @slides = document.getElementsByClassName(@sliderClass)
    @slideControls = document.getElementsByClassName(@controlClass)
    @showSlide(0)
 
  showSlide: (index) =>
    slideIndex = index
    sliderImage = $(@slides[slideIndex]).data('image')
    @clearSlideControls()
    @clearSlides()
    $(@slides[slideIndex]).attr(
      'style',
      "display: block; background:url('#{sliderImage}'); background-repeat: no-repeat; background-size: cover;"
    );
    $(@slideControls[slideIndex]).addClass('active');

  clearSlides: =>
    $(@slides).each ->
      $(this).attr('style', 'display:none')
  
  clearSlideControls: =>
    $(@slideControls).each ->
      $(this).removeClass('active')
    
  sliderControlListener: =>
    self = this;
    $(@slideControls).on 'click', (event) ->
      targetId = $(this).data('index')
      self.showSlide(targetId)
  
  animateSlider: =>
    self = this
    slideIndex = 1
    setInterval () ->
      self.showSlide(slideIndex)
      slideIndex += 1
      if slideIndex == $(self.slides).length
        slideIndex = 0;
    ,10000
