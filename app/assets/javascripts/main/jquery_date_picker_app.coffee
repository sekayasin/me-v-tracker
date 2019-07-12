class JqueryDatePicker.App
  constructor: (options = {
    datePickerId: 'select_start_date',
    minDate: '0D',
    closeText: 'OK',
    dateFormat: 'dd-mm-yy',
    showButtonPanel: true }) ->
    @ui = new JqueryDatePicker.UI(options)
    @headerHtml = $('#material-header-holder .ui-datepicker-material-header')

  start: ->
    @ui.initializeDatePicker(@headerHtml)
    @ui.activateHeader(@headerHtml)
    @selectToday()
  

  selectToday: ->
    self = @
    isInitialized = $.datepicker._gotoToday.toString().includes('(id)')
    
    if (!isInitialized)
      $.datepicker._gotoTodayOverload = $.datepicker._gotoToday

      $.datepicker._gotoToday = (id) ->
        $.datepicker._gotoTodayOverload id
        $.datepicker._selectDate id
        self.headerHtml.remove()
        self.ui.prependHeader(self.headerHtml)
