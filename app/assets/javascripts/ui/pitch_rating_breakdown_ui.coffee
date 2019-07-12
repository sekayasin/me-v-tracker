class Pitch.PitchRatingBreakdown.UI
  constructor: (api) ->

  initialize: ->
    @registerEventListeners()

  registerEventListeners: ->
    self = @
    $(".tab-btn-back-icon").on 'click', () ->
      window.location.href = "/pitch/#{pageUrl[2]}"

    $(".one-panelist").on 'click', (e) ->
      $(".one-panelist").each(() ->
        if $(this).hasClass('one-panelist-active')
          $(this).removeClass('one-panelist-active')
        );
      $(this).addClass('one-panelist-active')
