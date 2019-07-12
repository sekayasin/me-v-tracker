require "rails_helper"

RSpec.describe SurveySectionSerializer, type: :serializer do
  let(:admin) { create(:user, :admin) }
  let!(:new_survey) { create(:new_survey) }
  let!(:survey_section) do
    create(:survey_section, new_survey_id: new_survey.id)
  end
  let(:survey_question) do
    create(:survey_question, survey_section_id: survey_section.id)
  end
  subject { described_class }

  it "checks that the response is not empty" do
    response = subject.new(survey_section).to_json
    expect(response).not_to be_nil
  end

  it "return a hash" do
    response = subject.new(survey_section).to_json
    expect(JSON.parse(response)).to be_a Object
  end

  it "has survey_questions" do
    response = subject.new(SurveySection.first).to_json
    expect(JSON.parse(response)["survey_questions"]).not_to be_nil
  end

  it "returns survey_questions as array" do
    response = subject.new(survey_section).to_json
    expect(JSON.parse(response)["survey_questions"]).to be_a Array
  end
end
