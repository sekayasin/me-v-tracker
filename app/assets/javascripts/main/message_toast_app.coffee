class MessageToast.App
  constructor: ->
    @ui = new MessageToast.UI()
    
  start: (text, errorType='success') =>
    @ui.renderMessageToast(text, errorType)
