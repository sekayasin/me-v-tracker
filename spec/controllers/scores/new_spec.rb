require "rails_helper"

RSpec.describe ScoresController, type: :controller do
  let(:user) { create :user }
  let(:bootcamper) { create :bootcamper }
  let(:cadence) { create :cadence, days: 1 }
  let(:program) do
    create :program, estimated_duration: 2, cadence_id: cadence.id
  end
  let(:learner_program) { create :learner_program, program_id: program.id }
  let!(:framework_criterium) { create :framework_criterium }
  let!(:assessment) do
    create :assessment,
           name: "Writing professionally",
           phases: [phase],
           framework_criterium: framework_criterium,
           context: "Medium Post",
           description: "Simple description"
  end
  let!(:phase) { Phase.create(name: "Learning Clinic") }

  before do
    stub_current_user(:user)
    get :new, params: { id: 1, learner_program_id: learner_program.id }
  end

  describe "GET #new" do
    it "renders the profile template" do
      expect(response).to render_template("profile/profile")
    end

    it "returns a success status code" do
      expect(response).to be_success
    end

    it "returns assessment count as 0 when program id is not found" do
      output = "{\"verified_assessments\":0,\"assessments_count\":0}"
      verified_outputs = controller.send(:verified_outputs, 123_223)
      expect(verified_outputs).to eq output
    end
  end
end
