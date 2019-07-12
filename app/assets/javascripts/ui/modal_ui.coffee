class Modal.UI
  constructor: (width, maxWidth, maxHeight, height) ->
    @width = width
    @maxWidth = maxWidth
    @maxHeight = maxHeight
    @height = height
  
  open: (element) ->
    self = @
    $("#{element} .modal").css("display", "block")
    $("#{element} .modal-bottom").css("display", "block")
    $(element).dialog({
      modal: true,
      responsive: true,
      width: self.width,
      maxWidth: self.maxWidth,
      maxHeight: self.maxHeight,
      height: self.height,
      fluid: true,
      resizable: false
    }, 'position', 'center').on "keydown", (evt) ->
      if evt.keyCode == $.ui.keyCode.ESCAPE
          $('body').css('overflow', "auto")

    $(".ui-dialog-titlebar").hide()

  close: (element)->
    $("#{element} .modal").css("display", "none")
    $("#{element} .modal-bottom").css("display", "none")
    $(element).dialog().dialog( "close" )
    $('body').css('overflow', "auto")

  initializeDropdown: (element)->
    $(element).selectmenu({
      icons: { button: "down.svg" }
    })

  setHeaderTitle:(target, title) ->
    @ui.setHeaderTitle(target, title)
