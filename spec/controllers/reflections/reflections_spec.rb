require "rails_helper"

RSpec.describe ReflectionsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe "POST #create" do
    before do
      @bootcamper = create :bootcamper
      @learner_program = create(:learner_program, bootcamper: @bootcamper)
      @feedback = create(:feedback, learner_program: @learner_program)
      stub_current_user(@bootcamper)
      user_info = {
        name: @bootcamper.name,
        email: @bootcamper.email,
        admin: false,
        andelan: false,
        picture: "",
        learner: true
      }
      session[:current_user_info] = user_info
    end

    context "when learner submits reflection" do
      before do
        post  :create,
              params: {
                reflection: {
                  comment: "sample comment",
                  feedback_id: @feedback.id
                }
              }
      end
      it "returns created reflection in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "the response has the correct content" do
        expect(json).to include "reflection"
        expect(json).to include "learner_programs_id"
        expect(json).to include "lfa_email"
        expect(json).to include "learner_name"
        expect(json).to include "phase_name"
        expect(json).to include "output_name"
      end
      it "reflection without a comment is denied" do
        post  :create,
              params: {
                reflection: {
                  comment: nil,
                  feedback_id: @feedback.id
                }
              }
        expect(controller).to set_flash[:error]
      end
      it "returns created reflection for right feedback has expected content" do
        json_response = JSON.parse(response.body)
        feedback_id = json_response["reflection"]["feedback_id"]
        expect(feedback_id).to eq @feedback.id
      end
    end

    context "when learner tries to get a reflection" do
      before do
        @reflection = create(:reflection, feedback: @feedback)
        post  :show,
              params: { feedback_id: @feedback.id }
      end
      it "returns reflection in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "returned reflection has expected content" do
        expect(json).to include "id"
        expect(json).to include "comment"
        expect(json).to include "feedback_id"
      end
    end

    context "when learner tries to update a reflection" do
      before do
        @reflection = create(:reflection, feedback: @feedback)
        @new_commment = Faker::Lorem.paragraph
        put :update,
            params: {
              feedback_id: @feedback.id,
              comment: @new_commment
            }
      end
      it "returns reflection in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns an updated reflection has expected content" do
        updated_comment = json["comment"]
        expect(updated_comment).to eq @new_commment
      end
    end
  end
end
