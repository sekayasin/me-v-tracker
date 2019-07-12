# rubocop:disable Metrics/BlockLength
require "rails_helper"
require "rspec/json_expectations"

RSpec.describe AssessmentsController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let(:program) { Program.first }
  let!(:assessment) { create :assessment_with_phases }
  let(:bootcamper) { create :bootcamper_with_learner_program }

  output = {
    link: "this is a bad link",
    description: "This is a test description",
    assessment_id: 5,
    phase_id: 7
  }

  before do
    stub_current_user(:user)
    allow(controller).to receive(:admin?)
    allow(controller).to receive_message_chain(
      "helpers.admin?"
    ).and_return true
    @assessment = Assessment.first || create(:assessment_with_phases)
    @point = Point.first || create(:point, value: 0,
                                           context: "No output submitted")
    @metric = create(:metric, assessment: @assessment, point: @point)
  end

  describe "GET #get_framework_criteria" do
    context "when loading assessment details with program id" do
      before do
        get :get_framework_criteria, params: { program_id: program.id }
      end

      it "returns a json with a count of " do
        expect(json.count).to be >= 1
      end

      it "returns all criteria and frameworks" do
        expect(json).to include "frameworks"
        expect(json).to include "assessments"
      end

      it "returns the appropriate user role" do
        expect(json["is_admin"]).to eq true
      end
    end

    context "when loading assessment details with no program id" do
      before do
        get :get_framework_criteria
      end

      it "returns a json with lengh of " do
        expect(json.count).to be >= 1
      end

      it "returns all assessments" do
        expect(json).to include "assessments"
      end

      it "returns the appropriate user role" do
        expect(json["is_admin"]).to eq true
      end
    end
  end

  describe "GET #get_assessment_metrics" do
    before do
      get :get_assessment_metrics, params: { assessment_id: @assessment.id }
    end

    it "returns all metrics associated with an assessment" do
      expect(response.body).to include @metric.description
    end
  end

  describe "GET #get_completed_assessments" do
    let!(:learner_program) { create(:learner_program, program_id: 1) }
    let(:params) do
      {
        id: learner_program.bootcamper.id,
        learner_program_id: learner_program.id
      }
    end
    before do
      get :get_completed_assessments, params: params
    end

    it "returns all the assessments for the learner" do
      assessments = AssessmentFacade.new(params)
      expect(response.body).to eq assessments.completed_assessments.to_json
    end
  end

  describe "Get #all" do
    before do
      @phase = assessment.phases.last
      get :all, params: { id: @phase.id }
    end

    it "returns the assessments for a phase" do
      assessments = JSON.parse(@phase.assessments.to_json)
      framework = assessment.framework.name
      criterium = assessment.criterium.name
      expect(json[framework][criterium]).to include_json assessments
    end
  end
  describe "Get #get_phase_assessments" do
    before do
      get :get_phase_assessments, params: {
        phase_id: assessment.phases.last.id
      }
    end

    it "returns the assessments for the phase" do
      expect(response.body).to include FrameworkCriterium.last.id.to_s
    end

    context "when sent a paginated request with no filters" do
      before do
        get :get_framework_criteria, params: {
          program_id: program.id,
          paginate: true,
          offset: 0,
          limit: 5
        }
      end
      it "returns paginated response with no filters set" do
        expect(json["assessments"].size).to be <= 5
      end
    end

    context "when sent a paginated request with filters set" do
      before do
        get :get_framework_criteria, params: {
          program_id: program.id,
          paginate: true,
          offset: 0,
          limit: 3,
          framework_id: Framework.first.id
        }
      end

      it "returns paginated response with filters set" do
        expect(json["assessments"].size).to be <= 3
        expect(json["assessments"].first["framework"]).
          to eq(Framework.first.name)
      end
    end
  end

  describe "POST #submit_assessment_output" do
    context "when learner submits bad output" do
      before do
        session[:current_user_info] = bootcamper
        post :submit_assessment_output, params: output
      end

      it "responds with failed status and corresponding error message" do
        expect(json["saved"]).to eq(false)
        expect(json["errors"]["link"][0]).to eq(
          "must be a valid http:// or https:// url"
        )
      end
    end

    context "when learner submits good output" do
      before :each do
        output[:link] = "https://github.com/andela/vof-tracker"
        session[:current_user_info] = bootcamper
        post :submit_assessment_output, params: output
      end

      it "responds with saved output details" do
        expect(json["saved"]).to eq(true)
        expect(json["assessment_id"]).to eq(output[:assessment_id])
        expect(json["phase_id"]).to eq(output[:phase_id])
      end

      it "responds with failed status for re-submitting output" do
        post :submit_assessment_output, params: output
        expect(json["saved"]).to eq(false)
        expect(json["errors"]["submission"][0]).to eq(
          "for this output has already been provided"
        )
      end
    end

    context "when learner submits output for concluded cycle" do
      before do
        cycle_center = bootcamper.learner_programs.last.cycle_center
        cycle_center.end_date = Date.yesterday
        cycle_center.save
        session[:current_user_info] = bootcamper
        post :submit_assessment_output, params: output
      end

      it "responds with failed status and corresponding error message" do
        expect(json["saved"]).to eq(false)
        expect(json["errors"]["submission"][0]).to eq(
          "is not allowed for completed cycle"
        )
      end
    end
  end

  describe "PUT #update_assessment_output" do
    before do
      OutputSubmission.create(output)
      @output_update = {
        output_id: OutputSubmission.last.id,
        link: "this is a bad link",
        description: "This is right or not",
        assessment_id: 5,
        phase_id: 7
      }
      session[:current_user_info] = bootcamper
    end

    context "when learner tries updating output with invalid link" do
      before do
        put :update_assessment_output, params: @output_update
      end
      it "responds with failed status and corresponding error message" do
        expect(json["saved"]).to eq(false)
        expect(json["errors"]["link"][0]).to eq(
          "must be a valid http:// or https:// url"
        )
      end
    end

    context "when learner tries updating good output" do
      before do
        @output_update[:link] = "https://github.com/andela/vof-tracker"
        put :update_assessment_output, params: @output_update
      end

      it "responds with saved updated output details" do
        expect(json["saved"]).to eq(true)
        expect(json["assessment_id"]).to eq(@output_update[:assessment_id])
      end
    end

    context "when learner updates output for concluded cycle" do
      before do
        cycle_center = bootcamper.learner_programs.last.cycle_center
        cycle_center.end_date = Date.yesterday
        cycle_center.save
        put :update_assessment_output, params: @output_update
      end

      it "responds with failed status and corresponding error message" do
        expect(json["saved"]).to eq(false)
        expect(json["errors"]["submission"][0]).to eq(
          "is not allowed for completed cycle"
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
