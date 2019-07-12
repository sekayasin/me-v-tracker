require "rails_helper"
require "helpers/survey_response_helper_spec"
require_relative "../../helpers/add_survey_v2_respond_helper_spec.rb"

RSpec.describe SurveysV2RespondController, type: :controller do
  RSpec.configure do |c|
    c.include SurveyResponseHelper
  end

  describe "POST #create" do
    let(:cycle_center) { create(:cycle_center) }
    let(:user) { create(:user) }
    let(:bootcamper) { create :bootcamper_with_learner_program }
    let(:survey) { create(:new_survey) }
    let(:survey_section) { create(:survey_section, new_survey_id: survey.id) }
    let(:scale_question) { create(:survey_scale_question) }
    let(:time_question) { create(:survey_time_question) }
    let(:date_question) { create(:survey_date_question) }
    let(:paragraph_question) { create(:survey_paragraph_question) }
    let(:option_question) { create(:survey_option_question) }

    let(:survey_response) do
      create(:survey_response, new_survey_id: survey.id)
    end
    let(:scale_response) do
      create(:survey_scale_response,
             survey_response_id: survey_response.id,
             question_id: scale_question.id)
    end
    let(:time_response) do
      create(:survey_time_response,
             survey_response_id: survey_response.id,
             question_id: time_question.id)
    end
    let(:date_response) do
      create(:survey_date_response,
             survey_response_id: survey_response.id,
             question_id: date_question.id)
    end
    let(:paragraph_response) do
      create(:survey_paragraph_response,
             survey_response_id: survey_response.id,
             question_id: paragraph_question.id)
    end
    let(:multichoice_response) do
      create(:survey_option_response,
             :multichoice,
             survey_response_id: survey_response.id,
             question_id: option_question.id)
    end
    let(:image_option_response) do
      create(:survey_option_response,
             :picture_option,
             survey_response_id: survey_response.id,
             question_id: option_question.id)
    end
    let(:dropdown_response) do
      create(:survey_option_response,
             :dropdown,
             question_id: option_question.id)
    end
    let(:multi_grid_response) do
      multichoice_grid_helper
    end
    let(:checkbox_grid_response) do
      checkbox_grid_helper
    end
    let(:checkbox_response) do
      checkbox_helper
    end
    let(:image_checkbox_response) do
      picture_checkbox_helper
    end

    namespace = {}

    before do
      stub_current_user(:user)
      session[:current_user_info] = bootcamper
      @new_survey = survey
      @new_section = survey_section
      @survey_questions = create_questions
      @question_option = @survey_questions[4]
      namespace["question_#{@survey_questions[0].id}"] = scale_response
      namespace["question_#{@survey_questions[1].id}"] = time_response
      namespace["question_#{@survey_questions[2].id}"] = date_response
      namespace["question_#{@survey_questions[3].id}"] = paragraph_response
      namespace["question_#{@question_option[0].id}"] = multichoice_response
      namespace["question_#{@question_option[1].id}"] = image_option_response
      namespace["question_#{@question_option[2].id}"] = dropdown_response
      namespace["question_#{@question_option[3].id}"] = multi_grid_response
      namespace["question_#{@question_option[4].id}"] = checkbox_grid_response
      namespace["question_#{@question_option[5].id}"] = checkbox_response
      namespace["question_#{@question_option[6].id}"] = image_checkbox_response
    end

    context "survey_response" do
      it "creates a response" do
        survey_responses = namespace
        submission_succeeds(@new_survey, survey_responses)
      end
    end
  end
end
