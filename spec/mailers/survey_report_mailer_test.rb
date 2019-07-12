require "test_helper"

class SurveyReportMailerTest < ActionMailer::TestCase
  test "survey_report" do
    mail = SurveyReportMailer.survey_report
    assert_equal "Survey report", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
