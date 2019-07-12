class ColumnFilter.UI
  hideUncheckedColumn: ->
    $('.colum-filter-list input:checkbox:not(:checked)').each ->
      column = 'table .' + $(this).attr('name')
      $(column).hide()
  
  toggleColumn: ->
    totalColumn = $('.colum-filter-list > li > label > input:checked').length + 1
    self = @
    $('.colum-filter-list > li > label > input').click ->
      column = 'table .' + $(this).attr('name')
      $(column).fadeToggle()
      if $(this).is(':checked')
        totalColumn += 1
      else
        totalColumn -= 1
      self.adjustColumnAlignment(totalColumn)
  
  adjustColumnAlignment: (totalColumn)->
    if totalColumn < 3
      $('th.status-color.filter').css('width', '2.8rem')
    else
      $('th.status-color.filter').css('width', '2.3rem')

  filterColumn: =>
    @hideUncheckedColumn()
    @toggleColumn()
