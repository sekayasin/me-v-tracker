require "rails_helper"

RSpec.describe SurveyResponseMailer, type: :mailer do
  let!(:bootcamper) { create(:bootcamper) }
  let(:survey) { create(:new_survey) }

  it "notify_unresponded_survey" do
    mail = SurveyResponseMailer.notify_unresponded_survey(bootcamper, survey)
    assert_equal "Survey Response", mail.subject
    assert_equal [bootcamper.email], mail.to
    assert_equal ["no-reply@vof.andela.com"], mail.from
    assert_match survey.title, mail.body.encoded
  end
end
