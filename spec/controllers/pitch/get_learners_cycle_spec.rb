require "rails_helper"

RSpec.describe PitchController, type: :controller do
  let(:user) { create :user }
  describe "GET #active program cycle and learners in cycle" do
    before(:each) do
      stub_current_user(:user)
      @program = create(
        :program,
        save_status: true
      )
      @center = create(
        :center,
        name: "Lagos",
        country: "Nigeria"
      )
      @cycle = create(:cycle)
      @camper = create(:bootcamper)
      @cycle_center = create(
        :cycle_center,
        center_id: @center[:center_id],
        cycle_id: @cycle[:cycle_id],
        program_id: @program[:id],
        end_date: Date.tomorrow
      )
      @learner_program = create(
        :learner_program,
        camper_id: @camper[:camper_id],
        cycle_center_id: @cycle_center[:cycle_center_id],
        program_id: @program[:id],
        decision_one: "Advanced"
      )
    end

    after(:each) do
      @learner_program.destroy
      @cycle_center.destroy
      @camper.destroy
      @cycle.destroy
      @center.destroy
      @program.destroy
    end

    it "returns learners in active cycles" do
      get :get_learners_cycle, params: {
        cycle_center_id: @cycle_center.cycle_center_id
      }
      expect(response.status).to eq(200)
      expect(response.body).to include(@learner_program.camper_id)
    end

    it "returns active cycle centres in program" do
      get :get_program_cycle, params: { program_id: @program.id }
      expect(response.status).to eq(200)
      expect(response.body).to include(@cycle_center.cycle_center_id,
                                       @center.name)
    end
  end
end
