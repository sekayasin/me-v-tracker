require "rails_helper"
require "spec_helper"
require "helpers/program_nps_helper_spec"

RSpec.describe ProgramNpsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:user) { create :user }
  let(:bootcamper) { create :bootcamper_with_learner_program }

  RSpec.configure do |c|
    c.include ProgramNpsHelper
  end

  before do
    create_program_feedback_data
    stub_current_user :bootcamper
    session[:current_user_info] = @learner_prog.bootcamper
  end

  describe "POST #save_program_feedback" do
    context "when a learner tries to save program feedback" do
      before do
        post :save_program_feedback, params: {
          rating: @nps_response.rating,
          question: @nps_question.question,
          program: @learner_prog.id
        }
      end

      it "returns learner's feedback in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns JSON with count" do
        expect(json.count).to be >= 1
      end
      it "returns feedback response of learner" do
        expect(json).to include "nps_response_id"
      end
      it "returns program feedback question" do
        expect(json).to include "nps_question_id"
      end
      it "returns expected learner's cycle center" do
        expect(json).to include "cycle_center_id"
      end
    end

    context "when a learner saves feedback without a rating" do
      it "throws validation error" do
        expect do
          post :save_program_feedback, params: {
            question: @nps_question.question,
            program: @learner_prog.id
          }
        end.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context "gets data for scheduling feedback popup" do
      before do
        get :get_program_feedback_details
      end

      it "returns data for program feedback" do
        expect(json).to include "data"
      end

      it "returns all program feedback questions" do
        expect(json).to include "questions"
      end
    end
  end
end
