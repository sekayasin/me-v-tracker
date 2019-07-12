require "rails_helper"

RSpec.describe LearningEcosystemController, type: :controller do
  let(:user) { create :user }
  let!(:bootcamper) { create :bootcamper_with_learner_program }
  let!(:phase) { create_list(:phase_with_assessments, 7) }
  let(:json) { JSON.parse(response.body) }

  describe "GET #get_learner_ecosystem_phases" do
    before do
      stub_current_user :user
      session[:current_user_info] = bootcamper
    end

    context "when a learner goes to the phases tab" do
      before do
        @phases = Phase.last(7).each do |phase|
          create :programs_phase,
                 phase_id: phase.id,
                 program_id: bootcamper.learner_programs.last.program_id
        end
        get :get_learner_ecosystem_phases
      end

      it "gets all the framework" do
        expect(json[0]). to include "assessments"
        expect(json[0]). to include "name"
        expect(json[0]). to include "id"
      end

      it "returns phases with due dates" do
        get :get_learner_ecosystem_phases
        json.each do |phase|
          expect(phase.key?("due_date")).to eq true
          expect(phase["due_date"]).not_to be_nil
        end
      end
    end
  end
end
