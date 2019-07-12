$(document).ready ->
  survey = new Survey.App()
  survey.start()

  dropDown = new JqueryDropdown.App({
    selectDropdownClass: 'create-survey-dropdown'
  })
  dropDown.start()

  dateTimePickerProps = {
    controlType: 'select',
    oneLine: true,
    stepMinute: 5,
    dateFormat: 'dd M yy',
    timeFormat: 'HH:mm',
    minDate: '0D',
  }

  $("#select_start_date_survey").datetimepicker(dateTimePickerProps)
  $("#select_end_date_survey").datetimepicker(dateTimePickerProps)
  $("#select_start_date_feedback").datetimepicker(dateTimePickerProps)
  $("#select_end_date_feedback").datetimepicker(dateTimePickerProps)
  $("#survey_share_start_date").datetimepicker(dateTimePickerProps)
  $("#survey_share_end_date").datetimepicker(dateTimePickerProps)
