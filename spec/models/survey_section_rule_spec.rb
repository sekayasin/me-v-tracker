require "rails_helper"

RSpec.describe SurveySectionRule, type: :model do
  describe "Test survey section rule" do
    let(:survey) do
      create(:new_survey)
    end

    let(:section) do
      create(:survey_section,
             new_survey_id: survey.id)
    end

    let(:survey_option_question) do
      create(:survey_option_question)
    end

    let(:option) do
      create(:survey_option,
             survey_option_question_id: survey_option_question.id)
    end

    context "survey section rule associations" do
      it { should belong_to(:survey_section) }
      it { should belong_to(:survey_option) }
    end

    context "when creating a valid survey section rule" do
      let(:rule) do
        build(:survey_section_rule,
              survey_section_id: section.id,
              survey_option_id: option.id)
      end

      it "creates a survey section rule" do
        expect(rule.valid?).to eq(true)
        expect(rule.save).to eq(true)
      end
    end
  end
end
