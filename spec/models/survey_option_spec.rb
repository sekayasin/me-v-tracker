require "rails_helper"

RSpec.describe SurveyOption, type: :model do
  describe "Test for survey options" do
    context "association" do
      it { should belong_to(:survey_option_question) }
    end

    context "survey option option type" do
      let(:survey_option_question) do
        create(:survey_option_question)
      end

      context "when saving with invalid option" do
        let(:option) do
          build(:survey_option, :wrong_option_type,
                survey_option_question_id: survey_option_question.id)
        end

        it "does not create with invalid option" do
          expect(option.valid?).to eq(false)
          expect(option.save).to eq(false)
        end
      end

      context "when saving without position" do
        let(:option) do
          build(:survey_option, :with_row, :without_position,
                survey_option_question_id: survey_option_question.id)
        end

        it "does not create without position" do
          expect(option.valid?).to eq(false)
          expect(option.save).to eq(false)
        end
      end

      context "when saving with valid option passed" do
        let(:option) do
          build(:survey_option,
                survey_option_question_id: survey_option_question.id)
        end

        it "creates with valid option" do
          expect(option.valid?).to eq(true)
          expect(option.save).to eq(true)
        end
      end

      context "when saving with position" do
        let(:option) do
          build(:survey_option, :with_row, :with_position,
                survey_option_question_id: survey_option_question.id)
        end

        it "creates with position" do
          expect(option.valid?).to eq(true)
          expect(option.save).to eq(true)
        end
      end
    end
  end
end
