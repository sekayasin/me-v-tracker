class MessageToast.UI
  constructor: ->
    @toastHeight = 60
    @currentToast = 0

  renderMessageToast: (text, errorType='success') ->
    self = @
    @buildMessageToast()

    toast = $(document).find(".toast#toast-#{@currentToast}")
    toast.addClass('shown')
    toast.addClass('show-'+errorType)
    toast.text(text)
    setTimeout (->
      toast.removeClass('shown')
      toast.removeClass('show-'+errorType)
      toast.text('')
      $("#toast-#{self.currentToast}").remove()
      $("body").find(".toast").each ->
        if $(@).attr('class') == "toast"
          $(@).remove()
      return
    ), 3000
  
  buildMessageToast: ->
    if $(document).find('.toast').length == 0
      @currentToast = 0;
      $('body').append("<div id='toast-0' style='top:7%' class='toast'></div>")
    else
      displayedToasts = $(document).find('.shown')
      totalToasts = displayedToasts.length
      @currentToast = totalToasts
      $('body').append("<div id='toast-#{totalToasts}' style='top:#{7+(9*totalToasts)}%' class='toast'></div>")
