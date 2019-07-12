isTouchDevice = ->
  try
    document.createEvent 'TouchEvent'
    return true
  catch e
    return false
  return

$('input').focus ->
  if isTouchDevice()
    $('html, body, #edit-personal-details-modal').animate { scrollTop: $(this).offset().top }, 1000
  return
