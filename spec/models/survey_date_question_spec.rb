require "rails_helper"

RSpec.describe SurveyDateQuestion, type: :model do
  describe "Test for survey date" do
    context "survey date associations" do
      it { should have_one(:survey_question) }
    end

    context "when saving with invalid dates" do
      let(:question) do
        build(:survey_date_question,
              :wrong_min_max_type)
      end

      it "creates with min and max dates missing" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end

    context "when saving with valid dates" do
      let(:question) do
        build(:survey_date_question)
      end

      it "creates with valid dates" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end
  end
end
