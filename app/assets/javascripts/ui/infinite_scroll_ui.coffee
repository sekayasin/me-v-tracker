class InfiniteScroll.UI
  constructor: ->
    @scrollBottomStatus = false

  removeLoader: =>
    $('#loader').removeClass 'loader'

  getScrollBottomStatus: =>
    return @scrollBottomStatus

  setScrollBottomStatus: (scrollBottomStatus) =>
    @scrollBottomStatus = scrollBottomStatus

  findElement: (parentElement, elementSelector) =>
    return parentElement.find($(elementSelector))

  getTableRecords: (elementSelector) =>
    return document.querySelector(elementSelector)
