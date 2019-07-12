module SendSurveyBroadcastHelpers
  def set_up
    @survey_pivot = create(:survey_pivot)
    SendSurveyBroadcastJob.perform_now(@survey_pivot.survey, "close")
  end

  def tear_down
    @survey_pivot.delete
  end
end
