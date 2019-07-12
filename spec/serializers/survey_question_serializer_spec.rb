require "rails_helper"

RSpec.describe SurveyQuestionSerializer, type: :serializer do
  let(:admin) { create(:user, :admin) }
  let!(:new_survey) { create(:new_survey) }
  let!(:survey_section) do
    create(:survey_section, new_survey_id: new_survey.id)
  end
  let(:survey_scale_question) do
    create(:survey_scale_question)
  end
  let!(:survey_date_question) { create(:survey_date_question) }
  let!(:date_params) do
    {
      survey_section_id: survey_section.id,
      questionable_type: "SurveyDateQuestion",
      questionable_id: survey_date_question.id
    }
  end
  let(:survey_question_2) do
    create(:survey_question, date_params)
  end
  let!(:params) do
    {
      survey_section_id: survey_section.id,
      questionable_type: "SurveyScaleQuestion",
      questionable_id: survey_scale_question.id
    }
  end
  let(:survey_question) do
    create(:survey_question, params)
  end
  let(:survey_option) do
    create(:survey_option, survey_question.id)
  end

  let!(:questionable_type) { "SurveyOptionQuestion" }
  let!(:new_params) do
    {
      survey_section_id: survey_section.id,
      questionable_type: questionable_type,
      questionable_id: survey_scale_question.id
    }
  end
  let(:new_survey_question) do
    create(:survey_question, new_params)
  end
  subject { described_class }

  it "reaches the survey question method" do
    response = subject.new(survey_question).survey_question
    expect(response).to be_a Object
  end
  it "reaches the type method" do
    response = subject.new(survey_question).type
    expect(response).to be_a Object
  end
  it "reaches the survey_options method" do
    response = subject.new(survey_question).survey_options
    expect(response).to be_a Object
  end
  it "reaches the scale method" do
    response = subject.new(survey_question).scale
    expect(response).to be_a Object
  end
  it "reaches the date method" do
    response = subject.new(survey_question_2).date_limits
    expect(response).to be_a Object
  end
  it "must not be empty" do
    response = subject.new(survey_question).to_json
    expect(response).not_to be_nil
  end

  it "returns a hash" do
    response = subject.new(survey_question).to_json
    expect(JSON.parse(response)).to be_a Object
  end

  it "has scale" do
    response = subject.new(survey_question).to_json
    expect(JSON.parse(response)["scale"]).to be_a Object
  end
  it "has max scale equals 10" do
    response = subject.new(survey_question).to_json
    expect(JSON.parse(response)["scale"]["max"]).to eq(10)
  end
  it "has min scale equals 1" do
    response = subject.new(survey_question).to_json
    expect(JSON.parse(response)["scale"]["min"]).to eq(1)
  end

  it "includes survey_options as an empty array" do
    response = subject.new(survey_question).to_json
    expect(JSON.parse(response)).to include("survey_options")
  end

  it "includes questionable_type" do
    response = subject.new(survey_question).to_json
    expect(JSON.parse(response)).to include("type")
  end
  context "#survey_option_rows" do
    it "has option rows" do
      questionable = survey_question.questionable_type
      response = subject.new(survey_question).to_json
      if questionable == questionable_type
        expect(JSON.parse(response)).to include("rows")
      else
        expect(JSON.parse(response)).not_to include("rows")
      end
    end
  end
  context "#survey_option_columns" do
    it "has columns" do
      questionable = survey_question.questionable_type
      response = subject.new(survey_question).to_json
      if questionable == questionable_type
        expect(JSON.parse(response)).to include("columns")
      end
    end
    it "has not columns" do
      questionable = survey_question.questionable_type
      response = subject.new(survey_question).to_json
      if questionable != questionable_type
        expect(JSON.parse(response)).not_to include("columns")
      end
    end
  end
end
