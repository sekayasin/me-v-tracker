require "rails_helper"
require_relative "../helpers/new_survey_model_spec_helper.rb"

RSpec.describe NewSurvey, type: :model do
  describe "Test New Survey" do
    context "new survey associations" do
      it { should have_many(:survey_sections) }
      it { should have_many(:collaborators) }
      it { should have_many(:new_survey_collaborators) }
    end

    context "when trying to create a survey with no status" do
      no_status_helper
      it "creates a survey with default status" do
        valid_survey_helper(survey)
        expect(survey.status).to eq("draft")
      end
    end

    context "when trying to create a survey with published status" do
      published_helper
      it "creates a survey with published status" do
        valid_survey_helper(survey)
        expect(survey.status).to eq("published")
      end
    end

    context "when trying to create a survey with draft status" do
      draft_helper
      it "creates a survey with draft status" do
        valid_survey_helper(survey)
        expect(survey.status).to eq("draft")
      end
    end

    context "when trying to create a survey with no title" do
      no_title_helper
      it "does not create a survey without title" do
        invalid_survey_helper(survey)
      end
    end

    context "when trying to create a survey with wrong status" do
      wrong_status_helper
      it "does not create a survey with wrong status" do
        invalid_survey_helper(survey)
      end
    end
  end
end
