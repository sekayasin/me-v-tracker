require "rails_helper"

RSpec.describe NewSurveySerializer, type: :serializer do
  let(:admin) { create(:user, :admin) }
  let!(:new_survey) { create(:new_survey) }
  let!(:survey_section) do
    create(:survey_section, new_survey_id: new_survey.id)
  end
  subject { described_class }

  it "not empty" do
    response = subject.new(new_survey).to_json
    expect(response).not_to be_nil
  end

  it "return a hash" do
    response = subject.new(new_survey).to_json
    expect(JSON.parse(response)).to be_a Object
  end

  it "has survey_sections" do
    response = subject.new(NewSurvey.first).to_json
    expect(JSON.parse(response)["survey_sections"]).not_to be_nil
  end

  it "returns survey_sections as array" do
    response = subject.new(new_survey).to_json
    expect(JSON.parse(response)["survey_sections"]).to be_a Array
  end
end
