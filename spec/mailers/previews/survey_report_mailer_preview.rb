class SurveyReportMailerPreview < ActionMailer::Preview
  def survey_report
    SurveyReportMailer.survey_report
  end
end
