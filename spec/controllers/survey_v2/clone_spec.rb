require "rails_helper"

RSpec.describe SurveysV2Controller, type: :controller do
  describe "Hitting the clone controller:" do
    let(:admin) { create(:user, :admin) }
    let(:survey) { create(:new_survey) }
    let(:scale_question) { create(:survey_scale_question) }
    let(:time_question) { create(:survey_time_question) }
    let(:date_question) { create(:survey_date_question) }
    let(:paragraph_question) { create(:survey_paragraph_question) }
    let(:option_question) { create(:survey_option_question) }
    let(:survey_section) { create(:survey_section, new_survey_id: survey.id) }

    def create_questions
      create(:survey_question,
             survey_section_id: survey_section.id,
             questionable_id: scale_question.id,
             questionable_type: "SurveyScaleQuestion")
      create(:survey_question,
             survey_section_id: survey_section.id,
             questionable_id: time_question.id,
             questionable_type: "SurveyTimeQuestion")
      create(:survey_question,
             survey_section_id: survey_section.id,
             questionable_id: date_question.id,
             questionable_type: "SurveyDateQuestion")
      create(:survey_question,
             survey_section_id: survey_section.id,
             questionable_id: paragraph_question.id,
             questionable_type: "SurveyParagraphQuestion")
      create(:survey_question,
             survey_section_id: survey_section.id,
             questionable_id: option_question.id,
             questionable_type: "SurveyOptionQuestion")
      create(:survey_option,
             survey_option_question_id: option_question.id)
    end

    def get_duplicate_survey(string)
      new_id = string.split(/id.*:(\d+).*title/)[1]
      NewSurvey.find_by_id!(new_id)
    end

    def get_cloned_options(id)
      SurveyOptionQuestion.find_by_id!(id).survey_options
    end

    before do
      survey[:status] = "draft"
      stub_current_user(:admin)
      session[:current_user_info] = admin.user_info
      create_questions
      get :clone_survey, params: { survey_id: survey.id }
      @cloned_survey = get_duplicate_survey(response.body.to_s)
      @cloned_survey_section = @cloned_survey.survey_sections
      @survey_questions = @cloned_survey_section.first.survey_questions
      @survey_questions.each do |cloned_item|
        next unless cloned_item.questionable_type == "SurveyOptionQuestion"

        @cloned_options = get_cloned_options(cloned_item.questionable_id)
      end
    end

    context "With a valid id" do
      it "clones the survey successfully" do
        expect(response.body).to include("Survey was successfully cloned")
        expect(response.status).to eq(201)
      end

      it "clones the survey data accurately" do
        survey.survey_responses_count = 0
        expect(@cloned_survey).to be_a_clone_of(survey, %w(status title))
        expect(@cloned_survey.title).to eq("Copy of #{survey.title}")
      end

      it "clones the survey section data accurately" do
        @cloned_survey_section.each do |cloned_survey_section_item|
          expect(cloned_survey_section_item).
            to be_a_clone_of(survey_section)
        end
      end

      it "clones the survey question data accurately" do
        questions_count = 0
        @survey_questions.each do |cloned_item|
          case cloned_item.questionable_type
          when "SurveyOptionQuestion"
            expect(cloned_item).
              to be_a_clone_of(option_question.survey_question)
            @cloned_options = get_cloned_options(cloned_item.questionable_id)
            questions_count += 1
          when "SurveyScaleQuestion"
            expect(cloned_item).
              to be_a_clone_of(scale_question.survey_question)
            questions_count += 1
          when "SurveyTimeQuestion"
            expect(cloned_item).
              to be_a_clone_of(time_question.survey_question)
            questions_count += 1
          when "SurveyDateQuestion"
            expect(cloned_item).
              to be_a_clone_of(date_question.survey_question)
            questions_count += 1
          when "SurveyParagraphQuestion"
            expect(cloned_item).
              to be_a_clone_of(paragraph_question.survey_question)
            questions_count += 1
          end
        end
        expect(questions_count).to eq(5)
      end

      it "clones the survey question options data accurately" do
        expect(@cloned_options.first).
          to be_a_clone_of(option_question.survey_options.first)
        expect(@cloned_options.last).
          to be_a_clone_of(option_question.survey_options.last)
      end

      it "chains the newly created data correctly" do
        @cloned_survey_section.each do |cloned_section|
          expect(cloned_section.new_survey_id).to eq(@cloned_survey.id)
          @survey_questions.each do |question|
            expect(question.survey_section_id).to eq(cloned_section.id)
            next unless question.questionable_type == "SurveyOptionQuestion"

            expect(@cloned_options.first.survey_option_question_id).
              to eq(question.questionable_id)
            expect(@cloned_options.last.survey_option_question_id).
              to eq(question.questionable_id)
          end
        end
      end
    end
  end

  describe "Creating a disconnected question" do
    let(:survey_with_disconnections) { create(:new_survey) }
    let(:survey_section_missing_question) do
      create(:survey_section, new_survey_id: survey_with_disconnections.id)
    end
    let(:scale_question) { create(:survey_scale_question) }

    def create_bad_question
      create(:survey_question,
             survey_section_id: survey_section_missing_question.id,
             questionable_id: -9,
             questionable_type: "SurveyScaleQuestion")
    end

    before do
      stub_current_user(:admin)
      create_bad_question
    end

    it "will fail to clone and destroy cloned survey" do
      get :clone_survey, params: { survey_id: survey_with_disconnections.id }

      expect(response.body).to include("Couldn't find SurveyScaleQuestion")
      expect(response.status).to eq(400)
    end
  end
end
