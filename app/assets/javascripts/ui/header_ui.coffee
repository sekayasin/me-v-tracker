class Header.UI
  constructor: ->
    @increaseMainSectionMargin()
    @handleNavItemClick()
    @showNavigationListDropdown()
    @showDLCOptions()
    @hideDLCOptions()
    @headerLearnerLinkAction()
    @clearLocalStorage()

  increaseMainSectionMargin: () =>
    if $('.navbar-nav').height() > 50
      $('.main-section').css('margin-top', '170px')

  handleNavItemClick: () =>
    $('.navbar-item-container').on 'click', (event) ->
      $('.navbar-item-container, .navbar-item-icon > span').removeClass 'active'
      $(@).addClass 'active'
      $(@).find('.navbar-item-icon > span').addClass 'active'

  showNavigationListDropdown: () =>
    $('.icon-bars').on 'click', () ->
      $(@).toggleClass 'change'
      $('.navigation-list-dropdown').slideToggle()

  showDLCOptions: () =>
    $('.mobile-dlc-options').on 'click', () ->
      $('.navigation-list-dropdown').hide()
      $('.mobile-select-dlc').show()
      $('.mdl-mini-footer').hide()

      $('.icon-bars').on 'click', () ->
        $(@).removeClass 'change'
        $(@).addClass 'change'
        $(@).toggleClass 'change'
        $('.mobile-select-dlc').hide()
        $('.mdl-mini-footer').show()
        $('.navigation-list-dropdown').hide()

        $('.icon-bars').on 'click', () ->
          $(@).toggleClass 'change'
          $('.navigation-list-dropdown').show()

  hideDLCOptions: () =>
    $('.select-dlc').on 'click', () ->
      $('.mobile-select-dlc').hide()
      $('.navigation-list-dropdown').show()

      $('.icon-bars').on 'click', () ->
        $(@).removeClass 'change'
        $(@).addClass 'change'
        $(@).toggleClass 'change'
        $('.navigation-list-dropdown').show()

  headerLearnerLinkAction: () =>
    programId = localStorage.getItem('programId')
    if programId
      $('.learner-link').attr('href', '/learners?program_id=' + programId)

  closeNotificationPane: =>
    $('.notifications-pane').animate({ right: '-263px' })
    $('body').css({ 'overflow': 'auto' });
    $('.notifications-pane-backdrop').hide()

  displayEmptyNotification: =>
    if ($('.notification').length == 0)
      $('.empty-notification-message').removeClass('hidden')

  clearLocalStorage: ->
    $('.logout-link').on 'click', ->
      localStorage.removeItem('programId')
      localStorage.removeItem('searchDetails')
