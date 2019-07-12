require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper.rb"
require_relative "../support/survey_v2_respond_helper"

describe "Learner surveys page" do
  before :all do
    @learner_program = create_survey_bootcamper
    @survey = create_list(:new_survey, 5, :published)
    @survey.each do |survey|
      survey.update(cycle_centers: [@learner_program.cycle_center])
      next if survey.id < 3

      SurveyResponse.create(
        new_survey_id: survey.id,
        respondable_id: @bootcamper.camper_id,
        respondable_type: "Bootcamper"
      )
    end
  end

  feature "Learner can view survey cards" do
    before do
      stub_different_users
      visit("/surveys-v2")
    end
    scenario "Learner should be able to navigate between pages" do
      expect(page).to have_content("Edit Response")
    end
  end
end

describe "Survey 2.0 respond page for users" do
  before :all do
    create_respond_bootcamper
    @survey = create(:new_survey, :published)
    prepare_optional_question
  end

  before(:each) do
    stub_non_andelan_bootcamper(@bootcamper)
    stub_current_session_bootcamper(@bootcamper)
    visit "/surveys-v2/respond/#{@survey.id}"
  end

  feature "Respond to a survey" do
    scenario "responses page" do
      expect(current_path).to eq("/surveys-v2/respond/#{@survey.id}")
    end

    scenario "Submit user response" do
      submit_user_response
      expect(page).to have_content("Response Successfully Submitted")
    end
  end
end
