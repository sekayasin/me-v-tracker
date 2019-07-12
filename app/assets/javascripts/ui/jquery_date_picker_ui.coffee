class JqueryDatePicker.UI
  constructor: ({
    datePickerId,
    minDate,
    closeText,
    dateFormat,
    showButtonPanel }) ->
    @datePicker = document.getElementById(datePickerId)
    @showButtonPanel = showButtonPanel
    @minDate = minDate
    @closeText = closeText
 
  initializeDatePicker: (header) ->
    @initializeJqueryDatePicker(header)
  
  initializeJqueryDatePicker: (headerHtml) ->
    $(@datePicker).datepicker
      showButtonPanel: @showButtonPanel
      minDate: @minDate
      closeText: @closeText
      dateFormat: 'yy-mm-dd'
      onSelect: (date, instance) =>
        @changeMaterialHeader headerHtml, moment(date, 'YYYY/MM/DD')

  activateHeader: (headerHtml) ->
    @changeMaterialHeader headerHtml, moment()
    $(@datePicker).on 'focus click', =>
      @prependHeader(headerHtml)

  changeMaterialHeader: (header, date) ->
    year = date.format('YYYY')
    month = date.format('MMM')
    dayNum = date.format('D')
    isoDay = date.isoWeekday()
    weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

    $('.ui-datepicker-material-day', header).text weekday[isoDay - 1]
    $('.ui-datepicker-material-year', header).text year
    $('.ui-datepicker-material-month', header).text month
    $('.ui-datepicker-material-day-num', header).text dayNum

  prependHeader: (headerHtml) ->
    $('.ui-datepicker').prepend headerHtml
