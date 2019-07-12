require "rails_helper"

RSpec.describe FeedbackController, type: :controller do
  include_context "feedback details"

  describe "GET #get_learner_feedback" do
    context "when param is valid or exists" do
      let(:learner_feedback) do
        get :get_learner_feedback, params: { details: feedback_param }
      end

      it "returns the learner's feedback" do
        expect(learner_feedback.body).to include "impression_id"
        expect(learner_feedback.body).to include learner_program[0].id.to_s
        expect(learner_feedback.body).to include phase.id.to_s
      end

      it "returns a 200 status" do
        expect(learner_feedback).to have_http_status 200
      end
    end

    context "when param is invalid or doesn't exist" do
      let(:learner_feedback) do
        get :get_learner_feedback, params: { details: feedback_param }
      end

      it "returns a null value" do
        feedback_param[:phase_id] = 1
        expect(learner_feedback.body).to eql "null"
      end
    end
  end
end
