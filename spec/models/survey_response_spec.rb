require "rails_helper"

RSpec.describe SurveyResponse, type: :model do
  describe "Test for survey response" do
    context "Correct validations" do
      it { should validate_presence_of :new_survey_id }
      it { should validate_presence_of :respondable_id }
      it { should validate_presence_of :respondable_type }
    end

    context "Child associations" do
      it { should have_many(:survey_date_responses) }
      it { should have_many(:survey_grid_option_responses) }
      it { should have_many(:survey_option_responses) }
      it { should have_many(:survey_paragraph_responses) }
      it { should have_many(:survey_time_responses) }
      it { should have_many(:survey_scale_responses) }
    end

    context "Parent associations" do
      it { should belong_to(:new_survey) }
      it { should belong_to(:respondable) }
    end
  end
end
