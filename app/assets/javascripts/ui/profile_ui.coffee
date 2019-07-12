class Profile.UI
  constructor: ->
    @modal = new Modal.App('.program-history-modal', 500, 500, 'auto', 'auto')
    
  missing_links = 0

  hideSocialLinks: () ->
    self = @
    github = $('.github .link-text')
    linkedin = $('.linkedin .link-text')
    trello = $('.trello .link-text')
    website = $('.website .link-text')

    if not self.exist(github) then self.hide('a.github')
    if not self.exist(linkedin) then self.hide('a.linkedin')
    if not self.exist(trello) then self.hide('a.trello')
    if not self.exist(website) then self.hide('a.website')
    if missing_links is 4 then self.hide('div.social-links')

  hide: (link) ->
    $(link).css("display", "none")
    missing_links += 1

  exist: (socialLink) ->
    socialLink.html().trim()?.length

  footerScrollAdjust: ->
    self = @
    $('.main-content').css('overflow', 'hidden')
    $('.score-section').css('height', 'auto')

  toggleHistoryModal: () ->
    self = @
    $(".view-program-history").click ->
      window.scrollTo(0, 0)
      self.modal.open()
      $('body').css('overflow', 'hidden')

      $('.ui-widget-overlay, #close-button, .close-modal').click ->
        self.modal.close()
        $('body').css('overflow', 'auto')

  toggleActivePhase: () ->
      active_phase = $('.assessment').attr("data-active-phase")
      $('.ui-menu-item').each ->
        if $(this).text() == active_phase
          $(this).css('background-color', '#D6EAF8')


  renderOnlyActivePhase: () ->
    self = @
    dropdown_button = document.getElementById('phase-dropdown-button')
    if dropdown_button
        return dropdown_button.addEventListener('click', ->
            self.toggleActivePhase()
        )
    setInterval ->
            return self.renderOnlyActivePhase()
          , 300
