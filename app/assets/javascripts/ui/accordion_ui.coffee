class Accordion.UI
  constructor: (
    accordionClass = 'accordion',
    accordionTitleClass = 'accordion-section-title',
    accordionContentClass = 'accordion-section-content'
  ) ->

    @accordion = document.getElementsByClassName(accordionClass)
    @accordionTitle = document.getElementsByClassName(accordionTitleClass)
    @accordionContent = document.getElementsByClassName(accordionContentClass)
    @timeout = 300

  closeAccordionSection: ->
    $(@accordionTitle).removeClass('active')
    $(@accordionContent).slideUp(@timeout).removeClass('open')

  toggleAccordion: ->
    self = @
    $(@accordionTitle).click (event) ->
      # Get current anchor value
      currentAttrValue = $(this).attr('href')

      if $(event.currentTarget).is('.active')
        self.closeAccordionSection()
      else
        self.closeAccordionSection()
        # Add active class to section title
        $(this).addClass('active')
        # Open up the hidden content panel
        $(currentAttrValue).slideDown(@timeout).addClass('open')

      event.preventDefault()

  initAccordion: =>
    @closeAccordionSection()
    @toggleAccordion()
