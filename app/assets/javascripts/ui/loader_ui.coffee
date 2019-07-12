class Loader.UI

  show: =>
    $(".main-content").addClass('loading')

  hide: =>
    $(".main-content").removeClass('loading')
