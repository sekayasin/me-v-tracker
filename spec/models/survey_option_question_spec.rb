require "rails_helper"

RSpec.describe SurveyOptionQuestion, type: :model do
  describe "Test for survey option" do
    context "survey option associations" do
      it { should have_one(:survey_question) }
    end

    context "when saving with wrong type" do
      let(:question) do
        build(:survey_option_question,
              :wrong_type)
      end

      it "does not create with wrong type" do
        expect(question.valid?).to eq(false)
        expect(question.save).to eq(false)
      end
    end

    context "when saving with valid type" do
      let(:question) do
        build(:survey_option_question)
      end

      it "creates with valid type" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end
  end
end
