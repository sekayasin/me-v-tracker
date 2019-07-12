require "rails_helper"

RSpec.describe ScoresController, type: :controller do
  let(:user) { create :user }
  let(:bootcamper) { create :bootcamper }
  let(:learner_program) { create :learner_program }
  let(:phase) { create :phase }
  let!(:framework_criterium) { create :framework_criterium }
  let!(:assessments) do
    create :assessment,
           name: "Writing professionally",
           phases: [phase],
           framework_criterium_id: framework_criterium.id,
           context: "Medium Post",
           description: "Simple description"
  end
  let(:params) do
    { scores: [{ score: 2,
                 comments: "good",
                 assessment_id: assessments.id,
                 phase_id: phase.id,
                 original_updated_at: "undefined" }],
      id: bootcamper.id,
      learner_program_id: learner_program.id }
  end

  before do
    request.headers["accept"] = "application/javascript"
    stub_current_user :user
  end

  describe "POST #create" do
    context "when an admin user scores a camper" do
      it "saves successfully" do
        allow(controller).to receive_message_chain(
          "helpers.admin?"
        ).and_return true

        stub_camper_progress(true)
        post :create, params: params
        expect(flash[:notice]).to eq "score-success"
      end
    end

    context "when the lfa scores a camper" do
      it "saves successfully" do
        allow(controller).to receive_message_chain(
          "helpers.user_is_lfa?"
        ).and_return true

        allow(controller).to receive_message_chain(
          "helpers.admin?"
        ).and_return false

        stub_camper_progress(true)
        post :create, params: params
        expect(flash[:notice]).to eq "score-success"
      end
    end
  end

  describe "POST create error" do
    context "when score params contain any empty value" do
      it "returns an error message" do
        allow(controller).to receive_message_chain(
          "helpers.admin?",
          "helpers.user_is_lfa?"
        ).and_return true

        post :create, params: { scores: [{ score: "",
                                           comments: "Good work",
                                           assessment_id: assessments.id,
                                           phase_id: phase.id }],
                                id: bootcamper.id,
                                learner_program_id: learner_program.id }
        expect(flash[:notice]).not_to eq "score-success"
      end
    end

    context "when comments are not passed" do
      it "returns an error message" do
        allow(controller).to receive_message_chain(
          "helpers.admin?",
          "helpers.user_is_lfa?"
        ).and_return true

        post :create, params: { scores: [{ score: 3,
                                           comments: "",
                                           assessment_id: assessments.id,
                                           phase_id: phase.id }],
                                id: bootcamper.id,
                                learner_program_id: learner_program.id }
        expect(flash[:notice]).not_to eq "score-success"
      end
    end

    context "when user who is not the lfa or admin scores a camper" do
      it "doesn't save score for the camper" do
        allow_any_instance_of(ApplicationHelper).to receive(
          :admin?
        ).and_return false

        allow_any_instance_of(ApplicationHelper).to receive(
          :user_is_lfa?
        ).and_return false

        post :create, params: { scores: [{ score: 1,
                                           comments: "Below expectation",
                                           assessment_id: assessments.id,
                                           phase_id: phase.id }],
                                id: bootcamper.id,
                                learner_program_id: learner_program.id }
        expect(response.body).to eq ""
      end
    end
  end
end
