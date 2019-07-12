require "rails_helper"
require "helpers/survey_helper_spec"
require_relative "../../helpers/add_survey_v2_controler_helper_spec.rb"

RSpec.describe SurveysV2Controller, type: :controller do
  RSpec.configure do |c|
    c.include SurveyHelper
  end

  let(:cycle_center) { create(:cycle_center) }
  let(:admin) { create(:user, :admin) }
  let(:survey) do
    survey_helper(cycle_center.cycle_center_id)
  end
  let(:base_question) do
    base_question_helper
  end
  let(:section_links) do
    section_links_helper
  end
  let(:grid_options) do
    grid_options_helper
  end
  let(:image_file) do
    Rack::Test::UploadedFile.new(
      "#{Rails.root}/spec/fixtures/output_file.png"
    )
  end
  let(:video_file) do
    Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/small.mp4")
  end
  let(:file_options) do
    file_option_helper(image_file)
  end
  before do
    stub_current_user(:admin)
    session[:current_user_info] = admin.user_info
    connection = Fog::Storage.new(provider: "AWS",
                                  aws_access_key_id: "access key",
                                  aws_secret_access_key: "secret key")
    allow(GcpService).to receive(:get_connection).and_return(connection)
    connection.put_bucket(GcpService::SURVEY_MEDIA_BUCKET)
  end

  describe "POST #create" do
    context "survey" do
      it "saves as draft" do
        survey["status"] = "draft"
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyCheckboxQuestion" }]
        save_succeeds(survey)
      end
      it "saves as published" do
        survey["status"] = "published"
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyCheckboxQuestion" }]
        save_succeeds(survey)
      end
    end
    context "base question" do
      it "fails to save without question" do
        survey["survey_questions"] =
          [{ **base_question, question: nil, type: "SurveyCheckboxQuestion" }]
        save_fails(survey)
      end

      it "fails to save without section" do
        survey["survey_questions"] =
          [{ **base_question, section: nil, type: "SurveyCheckboxQuestion" }]
        save_fails(survey)
      end

      it "fails to save without position" do
        survey["survey_questions"] =
          [{ **base_question, position: nil, type: "SurveyCheckboxQuestion" }]
        save_fails(survey)
      end

      it "saves without description" do
        survey["survey_questions"] =
          [{ **base_question, description: nil,
                              type: "SurveyCheckboxQuestion" }]
        save_succeeds(survey)
      end

      it "saves with image description" do
        survey["survey_questions"] =
          [{ **base_question, description: "file_1", description_type: "image",
                              type: "SurveyCheckboxQuestion" }]
        save_succeeds(survey, file_1: image_file)
      end

      it "saves with video description" do
        survey["survey_questions"] =
          [{ **base_question, description: "file_1", description_type: "video",
                              type: "SurveyCheckboxQuestion" }]
        save_succeeds(survey, file_1: video_file)
      end
    end

    context "option question" do
      it "fails to save with less than two options" do
        survey["survey_questions"] =
          [{ **base_question, survey_options: [{ option: "2" }],
                              type: "SurveyMultipleChoiceQuestion" }]
        save_fails(survey)
      end
    end

    context "multiple-choice questions" do
      it "saves a multiple choice question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyMultipleChoiceQuestion" }]
        save_succeeds(survey)
      end
    end

    context "checkbox questions" do
      it "saves a checkbox question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyCheckboxQuestion" }]
        save_succeeds(survey)
      end
    end

    context "select question" do
      it "saves a dropdown question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveySelectQuestion" }]
        save_succeeds(survey)
      end
    end

    context "scale question" do
      it "saves a scale question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyScaleQuestion",
                              scale: { min: 0, max: 5 } }]
        save_succeeds(survey)
      end
    end

    context "time question" do
      it "saves a time question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyTimeQuestion" }]
        save_succeeds(survey)
      end
    end

    context "date question" do
      it "saves a date question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyDateQuestion", date_limits: {} }]
        save_succeeds(survey)
      end
    end

    context "paragraph question" do
      it "saves a paragraph question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyParagraphQuestion" }]
        save_succeeds(survey)
      end
    end

    context "paragraph question" do
      it "saves a paragraph question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyParagraphQuestion" }]
        save_succeeds(survey)
      end
    end

    context "multigrid-multichoice question" do
      it "saves a multigrid-multichoice question" do
        survey["survey_questions"] =
          [{ **base_question, **grid_options,
            type: "SurveyMultigridOptionQuestion" }]
        save_succeeds(survey)
      end
    end

    context "multigrid-checkbox question" do
      it "saves a multigrid-checkbox question" do
        survey["survey_questions"] =
          [{ **base_question, **grid_options,
            type: "SurveyMultigridCheckboxQuestion" }]
        save_succeeds(survey)
      end
    end

    context "picture-option question" do
      it "saves a picture-option question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyPictureOptionQuestion",
                              survey_options: file_options[:survey_options] }]
        save_succeeds(survey, file_options[:files])
      end
    end

    context "picture-checkbox question" do
      it "saves a picture-checkbox question" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyPictureCheckboxQuestion",
                              survey_options: file_options[:survey_options] }]
        save_succeeds(survey, file_options[:files])
      end
    end

    context "with section link" do
      it "creates section rules" do
        survey["survey_questions"] =
          [{ **base_question, type: "SurveyMultipleChoiceQuestion" },
           { **base_question, type: "SurveyTimeQuestion", section: 2 }]
        survey["survey_section_links"] = { **section_links }
        save_succeeds(survey)
      end
    end
  end
end
