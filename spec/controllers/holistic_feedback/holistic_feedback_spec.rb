require "rails_helper"

RSpec.describe HolisticFeedbackController, type: :controller do
  include_context "holistic feedback details"

  before do
    stub_current_user :user
    allow(controller).to receive_message_chain(
      "helpers.user_is_lfa_or_admin?"
    ).and_return true
  end

  describe "POST #create" do
    it "returns success message and holistic feedback data" do
      post  :create,
            params: {
              id: bootcamper.id,
              learner_program_id: holistic_feedback.learner_program.id,
              holistic_feedback: {
                "0": {
                  comment: holistic_feedback.comment,
                  criterium_id: holistic_feedback.criterium.id
                }
              }
            }

      expect(json["message"]).to eq "success"
      expect(json["data"]["0"]["comment"]).to eq holistic_feedback.comment
    end

    it "returns a 200 status" do
      expect(response).to have_http_status 200
    end
  end
end
