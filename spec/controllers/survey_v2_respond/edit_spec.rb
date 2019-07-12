require "rails_helper"

RSpec.describe SurveysV2RespondController, type: :controller do
  let(:new_survey) { create :new_survey }
  let(:survey_response) do
    create(:survey_response,
           new_survey_id: new_survey.id)
  end
  let(:json) { JSON.parse(response.body) }
  before do
    stub_current_user(:bootcamper)
    @survey_response = survey_response
  end

  it "returns the survey response" do
    get :edit, params: {
      survey_id: new_survey.id
    }
    expect(json).not_to be_empty
    expect(json).to include %(survey_date_responses)
    expect(json).to include %(survey_grid_option_responses)
    expect(json).to include %(survey_option_responses)
    expect(json).to include %(survey_paragraph_responses)
    expect(json).to include %(survey_time_responses)
    expect(json).to include %(survey_scale_responses)
  end
end
