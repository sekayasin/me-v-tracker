require "rails_helper"

RSpec.describe SurveyParagraphQuestion, type: :model do
  describe "Test for paragraph question" do
    context "paragraph questions associations" do
      it { should have_one(:survey_question) }
    end

    context "when saving with invalid max_length" do
      let(:question) do
        build(:survey_paragraph_question,
              :wrong_max_length_type)
      end

      it "creates with max_length missing" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end

    context "when saving with max_length" do
      let(:question) do
        build(:survey_paragraph_question)
      end

      it "creates with valid max_length" do
        expect(question.valid?).to eq(true)
        expect(question.save).to eq(true)
      end
    end
  end
end
