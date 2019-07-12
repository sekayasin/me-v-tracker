require "rails_helper"

RSpec.describe SurveyScaleQuestion, type: :model do
  describe "Test for survey scale questions" do
    context "scale questions associations" do
      it { should have_one(:survey_question) }
    end

    context "when saving with invalid scale" do
      let(:question) do
        build(:survey_scale_question,
              :wrong_min_max)
      end

      it "does not create with invalid scale" do
        expect(question.valid?).to eq(false)
        expect(question.save).to eq(false)
      end
    end

    context "when saving without min" do
      let(:question) do
        build(:survey_scale_question,
              :no_min)
      end

      it "does not create with invalid scale" do
        expect(question.valid?).to eq(false)
        expect(question.save).to eq(false)
      end
    end

    context "when saving with valid scale" do
      let(:question) do
        build(:survey_scale_question)
      end

      it "creates with valid scale" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end
  end
end
