class FeedbackText.UI
  constructor: () ->

  handleFeedbackText: ->
    $('.feedback-icon').click ->
      feedback = $(this).attr('data-feedback')
      $(this).toggleClass("#{feedback}-active")
      if feedback == 'yes'
        $('.no-icon').removeClass('no-active')
      else
        $('.yes-icon').removeClass('yes-active')
      $(this).parent().find('.appreciation').css('display', 'inline-block').animate({
        margin: '0 0 0 10px'
      })
