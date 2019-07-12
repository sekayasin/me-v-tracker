require "rails_helper"

RSpec.describe SurveysV2Controller, type: :controller do
  describe "GET #respondents" do
    let(:bootcamper) { create :bootcamper_with_learner_program }
    let(:new_survey) { create :new_survey }
    let(:json) { JSON.parse(response.body) }
    let(:survey_response) do
      create(
        :survey_response,
        new_survey_id: new_survey.id,
        respondable_id: bootcamper.camper_id
      )
    end
    before do
      stub_current_user(:bootcamper)
      session[:current_user_info] = bootcamper
      @responded_survey = survey_response
    end

    it "returns active cycles" do
      get :get_respondents
      expect(response.status).to eq 200
      expect(json).not_to be_empty
    end
  end
end
