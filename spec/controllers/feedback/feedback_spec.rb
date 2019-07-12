require "rails_helper"

RSpec.describe FeedbackController, type: :controller do
  let(:user) { Bootcamper.find learner_program.first.camper_id }
  let(:json) { JSON.parse(response.body) }
  let(:phase) { create :phase }
  let(:program) { create :program }
  let(:feedback) do
    create :feedback, learner_program_id: learner_program.first.id,
                      phase: phase, assessment: assessment.first
  end

  include_context "feedback details"

  describe "GET #feedback_details" do
    before do
      session[:current_user_info] = user
      get :feedback_details, params: {
        learner_program_id: learner_program[0].id
      }, format: :json
    end

    it "fetches the learner's feedback details" do
      expect(json).to include impression[0].name
    end

    it "returns a 200 status" do
      expect(response).to have_http_status 200
      expect(response.body).to include phase.name
    end
  end

  describe "GET #get_lfa_feedback", :trial do
    before do
      request.env["HTTP_ACCEPT"] = "application/json"
      stub_current_user(:user)
      session[:current_user_info] = user
    end
    context do
      it "fetches the lfa feedback" do
        get :get_lfa_feedback, params: {
          phase_id: phase.id, assessment_id: assessment.first.id
        }
        expect(response.body).to include "Home Session 7"
        expect(response.body).to include "Well done"
        expect(response.content_type).to eq "application/json"
      end

      it "returns a success status code" do
        expect(response).to have_http_status 200
      end
    end
  end
end
