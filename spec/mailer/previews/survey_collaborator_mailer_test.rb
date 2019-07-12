require "test_helper"

class SurveyCollaboratorMailerTest < ActionMailer::TestCase
  test "invite_survey_collaborator" do
    mail = SurveyCollaboratorMailer.invite_survey_collaborator
    assert_equal "Share survey collaborator", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
