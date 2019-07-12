require "rails_helper"

RSpec.describe FeedbackController, type: :controller do
  include_context "feedback details"
  let(:json) { JSON.parse(response.body) }

  describe "POST #save_feedback" do
    context "when feedback exists" do
      it "updates the existing feedback details in the Feedback table" do
        post :save_feedback, params: { details: first_details }, xhr: true

        expect(Feedback.count).to eql(1)
        expect(Feedback.where(first_details).last.comment).
          to eql first_details[:comment]
        expect(json["assessment_name"]).to eql assessment[0].name
        expect(json["bootcamper_email"]).
          to eql learner_program[0].bootcamper.email
      end

      it "returns a 200 status" do
        expect(response).to have_http_status 200
      end
    end

    context "when feedback doesn't exist" do
      let(:phase) { create :phase, name: "Home Session 8" }

      it "creates the feedback details in the Feedback table" do
        second_details[:phase_id] = phase.id
        second_details[:comment] = "Nice work"
        post :save_feedback, params: { details: second_details }, xhr: true

        expect(Feedback.count).to eql(2)
        expect(Feedback.where(second_details).last.comment).
          to eql second_details[:comment]
        expect(json["assessment_name"]).to eql assessment[1].name
        expect(json["bootcamper_email"]).
          to eql learner_program[1].bootcamper.email
      end

      it "returns a 200 status" do
        expect(response).to have_http_status 200
      end
    end
  end
end
