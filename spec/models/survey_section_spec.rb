require "rails_helper"

RSpec.describe SurveySection, type: :model do
  describe "Test Survey Section" do
    let(:survey) do
      create(:new_survey)
    end

    context "survey section associations" do
      it { should have_many(:survey_questions) }
      it { should belong_to(:new_survey) }
    end

    context "when creating a valid survey section" do
      let(:section) do
        build(:survey_section,
              new_survey_id: survey.id)
      end

      it "creates a survey section" do
        expect(section.valid?).to eq(true)
        expect(section.save).to eq(true)
      end
    end

    context "when trying to create a survey section with no position" do
      let(:section) do
        build(:survey_section, :no_position,
              new_survey_id: survey.id)
      end
      it "does not create a section with no position" do
        expect(section.valid?).to eq(false)
        expect(section.save).to eq(false)
      end
    end
  end
end
