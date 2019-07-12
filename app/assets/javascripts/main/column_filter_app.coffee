class ColumnFilter.App
  constructor: ->
    @ui = new ColumnFilter.UI()
  
  start: =>
    @ui.filterColumn()
