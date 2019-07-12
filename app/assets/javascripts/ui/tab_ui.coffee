class Tab.UI
  constructor: (
    supportCardClass = 'support-card',
    tabHeaderClass = 'tab-header',
    tabContentClass = 'tab-content'
  ) ->

    @supportCard = document.getElementsByClassName(supportCardClass)
    @tabHeader = document.getElementsByClassName(tabHeaderClass)
    @tabContent = document.getElementsByClassName(tabContentClass)
    
  initializeTab: =>
    self = @
    $(@supportCard).click ->
      tabId = $(this).attr('data-tab')
      $(self.supportCard).removeClass('current support-card-active')
      $(self.tabHeader).removeClass('active-header')
      $(self.tabContent).removeClass('current')
      $(this).addClass('current support-card-active')
      $(this).find('h6').addClass('active-header')
      $('#' + tabId).addClass('current')

  
