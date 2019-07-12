require "rails_helper"

RSpec.describe SurveyTimeQuestion, type: :model do
  describe "Test for survey time questions" do
    context "survey time associations" do
      it { should have_one(:survey_question) }
    end

    context "when saving without min and max time" do
      let(:question) do
        build(:survey_time_question,
              :wrong_min_max_type)
      end

      it "saves without min and max time" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end

    context "when saving with valid times" do
      let(:question) do
        build(:survey_time_question)
      end

      it "creates with valid times" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end
  end
end
