require "rails_helper"
RSpec.describe LearnerProgramsController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let!(:learner_program) { create :learner_program }

  before do
    stub_current_user(:user)
    allow(controller).to receive_message_chain(
      "helpers.admin?"
    ).and_return true
  end

  describe "get #get_existing_program" do
    context "when a request is made to fetch the existing program" do
      before do
        get :get_existing_program, params: {
          program_id: learner_program.program.id,
          city: learner_program.cycle_center.center.name,
          cycle: learner_program.cycle_center.cycle.cycle
        }
      end
      it "gets the existing program" do
        expect(json["program_id"]).to eq learner_program.program.id
        expect(json["camper_id"]).to eq learner_program.bootcamper.id
      end
    end
  end
end
