require "rails_helper"

RSpec.describe SurveyGridOptionResponse, type: :model do
  describe "Test for survey option response" do
    context "option response associations" do
      it { should belong_to(:survey_response) }
    end
  end
end
