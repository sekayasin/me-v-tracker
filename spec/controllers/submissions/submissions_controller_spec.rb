require "rails_helper"
require "rspec/json_expectations"
require "helpers/submissions_helper_spec"
require "json"

RSpec.describe SubmissionsController, type: :controller do
  RSpec.configure do |c|
    c.include SubmissionsHelper
  end
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  before do
    first_db_setup
    second_db_setup
  end

  describe "GET #get_learner_submissions" do
    before do
      session[:current_user_info] = user.user_info
      stub_current_user(:user)

      @output = create(
        :output_submission,
        phase: @phase,
        learner_program: @learner_program,
        assessment: @assessment
      )
      allow(controller).to receive(:admin?).and_return(true)
    end

    context "when user tries to get bootcamper expected output" do
      before do
        get :get_learner_assessments_by_phases, params: {
          learner_program_id: @learner_program.id
        }
      end
      it "returns right content type" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns JSON with count" do
        expect(json.count).to be >= 1
      end
      it "returns due date entry" do
        expect(json[0]).to include "due_date"
      end
      it "returns expected expected ouput name" do
        expect(json[0]).to include "name"
      end
      it "returns expected expected ouput assessments" do
        expect(json[0]).to include "assessments"
      end
      it "returns an array of assessments" do
        expect(json[0]["assessments"].length).to be >= 1
      end
      it "returns assessments as expected" do
        expect(json[0]["assessments"][0]).to include "description"
      end
    end

    context "when user tries to view assessment" do
      before do
        get :get_learner_submissions, params: {
          learner_program_id: @learner_program.id
        }
      end
      it "renders HTML" do
        expect(response.headers["Content-Type"]).
          to eq "text/html; charset=utf-8"
      end
    end

    context "when user tries to view list of bootcampers with asseements" do
      before do
        session[:current_user_info] = user.user_info
        get :index
      end
      it "renders HTML" do
        expect(response.headers["Content-Type"]).
          to eq "text/html; charset=utf-8"
      end
    end

    context "when admin tries to filter by lfa and location" do
      before do
        get :index
        get :get_submissions, params: {
          filters: {
            lfas_week_one: [@week_one_lfa.id],
            lfas_week_two: [@week_two_lfa.id],
            cycles: [@cycle.cycle_id],
            locations: [@center.name]
          }
        }
      end
      it "returns right content type" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns JSON with count" do
        expect(json.count) == 1
      end
      it "returns JSON with required output" do
        expect(json).to include "paginated_data"
        expect(json).to include "submissions_count"
      end
      it "returns an array of paginated_data" do
        expect(json["paginated_data"].length).to be == 1
      end
    end

    context "when admin selects a location and cycle" do
      before do
        session[:current_user_info] = user.user_info
        get :index
        get :get_facilitators, params: {
          location: [@center.name],
          cycle: [@cycle.cycle_id]
        }
      end
      it "returns right content type" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns JSON with count" do
        expect(json.count) == 2
      end
      it "returns JSON with required output" do
        expect(json).to include "week_one"
        expect(json).to include "week_two"
        expect(json["week_one"].count).to eq 1
        expect(json["week_two"].count).to eq 1
      end
    end

    context "when admin searches for lfa with cycle option" do
      before do
        session[:current_user_info] = user.user_info
        get :index
        get :get_facilitators, params: {
          location: [@center.name],
          cycle: []
        }
      end
      it "returns right content type" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns JSON with count" do
        expect(json.count) == 2
      end
      it "returns JSON with empty data" do
        expect(json["week_one"].count).to eq 0
        expect(json["week_two"].count).to eq 0
      end
    end

    context "when a learner's decision one changes to rejected" do
      before do
        session[:current_user_info] = user.user_info
        third_db_setup
        get :get_submissions
      end
      it "returns right content type" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns JSON with count" do
        expect(json.count) == 2
      end
      it "returns an empty array of learners" do
        expect(json["paginated_data"]).to eq []
      end
      it "does not return any submissions from learner" do
        expect(json["submissions_count"]).to eq 0
      end
    end

    context "when user tries to get an ouput submission" do
      before do
        get :get_learner_output, params: {
          learner_program_id: @learner_program.id,
          assessment_id: @assessment.id
        }
      end
      it "returns right content type" do
        expect(response.content_type).to eq "application/json"
      end
      it "renders JSON with count" do
        expect(json.count).to be >= 1
      end
      it "returns an output" do
        expect(json).to include "is_multiple"
        expect(json).to include "outputs"
        expect(json).to include "submission_phases"
      end
    end

    context "when user tries to download an ouput submission" do
      before do
        @bucket = GcpService::LEARNER_SUBMISSIONS_BUCKET
        @connection = Fog::Storage.new(
          provider: "AWS",
          aws_access_key_id: "access key",
          aws_secret_access_key: "secret key"
        )
        allow(GcpService).to receive(:get_connection).and_return(@connection)
        @connection.put_bucket(@bucket)
        GcpService.upload("sample_file.png", "sample_file.png", @bucket)
        get :download_output, params: {
          file_name_id: "sample_file.png"
        }
      end
      it " downloads successfully" do
        expect(response.status).to eq 200
      end
    end
  end
end
