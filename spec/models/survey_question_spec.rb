require "rails_helper"

RSpec.describe SurveyQuestion, type: :model do
  describe "Test for survey scale questions" do
    context "scale questions associations" do
      it { should belong_to(:survey_section) }
      it { should belong_to(:questionable) }
    end

    context "survey question type" do
      let(:survey) do
        create(:new_survey)
      end

      let(:section) do
        create(:survey_section,
               new_survey_id: survey.id)
      end

      let(:scale_question) do
        create(:survey_scale_question)
      end

      context "when creating a valid survey question" do
        let(:question) do
          build(:survey_question,
                survey_section_id: section.id,
                questionable_id: scale_question.id,
                questionable_type: "SurveyScaleQuestion")
        end

        it "create a survey question" do
          expect(question.valid?).to eq(true)
          expect(question.save).to eq(true)
        end
      end

      context "when creating a survey question with no question" do
        let(:question) do
          build(:survey_question, :no_question,
                survey_section_id: section.id,
                questionable_id: scale_question.id,
                questionable_type: "SurveyScaleQuestion")
        end

        it "does not create a survey question without question" do
          expect(question.valid?).to eq(false)
          expect(question.save).to eq(false)
        end
      end

      context "when creating a survey question without description" do
        let(:question) do
          build(:survey_question, :wrong_description_type,
                survey_section_id: section.id,
                questionable_id: scale_question.id,
                questionable_type: "SurveyScaleQuestion")
        end

        it "does not create a survey question with wrong description type" do
          expect(question.valid?).to eq(false)
          expect(question.save).to eq(false)
        end
      end

      context "when creating survey question for no section or position" do
        let(:question) do
          build(:survey_question, :no_section, :no_position,
                questionable_id: scale_question.id,
                questionable_type: "SurveyScaleQuestion")
        end

        it "does not create a survey question with no position or section" do
          expect(question.valid?).to eq(false)
          expect(question.save).to eq(false)
        end
      end
    end
  end
end
