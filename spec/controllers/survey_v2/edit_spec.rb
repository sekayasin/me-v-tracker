require "rails_helper"

RSpec.describe SurveysV2Controller, type: :controller do
  let(:cycle_center) { create(:cycle_center) }
  let(:json) { JSON.parse(response.body) }
  let(:admin) { create(:user, :admin) }
  let!(:new_survey) { create(:new_survey) }
  let!(:survey_section) do
    create(:survey_section, new_survey_id: new_survey.id)
  end
  let(:new_attributes) do
    {
      title: "New Update",
      description: "This is a desc",
      recipients: [cycle_center.cycle_center_id],
      edit_response: true,
      end_date: 10.days.from_now,
      start_date: Time.now,
      survey_questions: [
        {
          section: 1,
          position: 1,
          question: "Question One",
          is_required: false,
          type: "SurveyScaleQuestion",
          scale: {
            min: 1,
            max: 8
          }
        }
      ],
      survey_id: new_survey.id,
      survey_section_links: {}
    }
  end
  let(:section_links) do
    {
      "section 2": { section_number: 1, question_number: 1, option_number: 1 }
    }
  end
  let(:invalid_attributes) do
    {
      title: "New Update",
      description: "This is a desc",
      recipients: [cycle_center.cycle_center_id],
      edit_response: true,
      end_date: 10.days.from_now,
      start_date: Time.now,
      survey_questions: [
        {
          section: 1,
          position: 1,

          is_required: false,
          type: "SurveyScaleQuestion",
          scale: {
            min: 1,
            max: 8
          }
        }
      ],
      survey_id: "new_survey.id",
      survey_section_links: {}
    }
  end
  let(:params) do
    {
      image: "http://localhost:9000/survey-media-staging
      /survey_option_image_file_4.png"

    }
  end
  subject { described_class }
  before do
    stub_current_user(:admin)
    session[:current_user_info] = admin.user_info
  end

  describe "GET edit" do
    context "when all required params are included" do
      it "renders the :setup view" do
        get :setup
        expect(response).to render_template(:setup)
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "Update Survey" do
    context "when survey successfully updates" do
      before do
        put :update_survey, params: { survey: new_attributes.to_json }
      end
      it "returns status code 201" do
        expect(response).to have_http_status(201)
      end

      it "updates new survey" do
        expect(json["message"]).to eq("Successfully updated survey")
      end
      it "renders a JSON response" do
        expect(response.content_type).to eq("application/json")
      end
    end

    context "with invalid params" do
      before do
        put :update_survey, params: { survey: invalid_attributes.to_json }
      end
      it "renders a JSON response" do
        expect(response.content_type).to eq("application/json")
      end
      it "returns status code 404" do
        expect(response).to have_http_status(404)
      end
      it "return a message" do
        expect(response.body).to include("Couldn't find NewSurvey")
      end
    end
  end

  describe "download image" do
    before do
      @connection = Fog::Storage.new(
        provider: "AWS",
        aws_access_key_id: "access key",
        aws_secret_access_key: "secret key"
      )
    end
    context "setup gcp connection and download image" do
      it "it should download file successfully" do
        @bucket = GcpService::SURVEY_MEDIA_BUCKET
        response = GcpService.download(@bucket, "survey_option_image_file_1")
        expect(response).to be_a Object
      end
    end
  end
end
