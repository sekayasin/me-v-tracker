require "rails_helper"

RSpec.describe ProgramsController, type: :controller do
  include_context "new program details"
  before do
    @program = create(
      :program,
      name: "Test Program",
      description: "Description for test program",
      estimated_duration: 13,
      holistic_evaluation: false
    )
    @phase = create :phase_with_assessments, name: "Audit"
    @first_assessment = create :assessment, name: "First Test Assessment"
    @second_assessment = create :assessment, name: "Second Test Assessment"
    @details = {
      id: @program.id,
      name: "Test Program name changed",
      description: "Description for test program",
      language_stacks: ["Python/Django"],
      estimated_duration: 5,
      phases: [
        {
          name: "New Phase",
          phase_duration: 1,
          phase_decision_bridge: false,
          assessments: [@second_assessment.id]
        },
        {
          id: @phase.id,
          name: @phase.name,
          phase_duration: 4,
          phase_decision_bridge: true,
          assessments: [@first_assessment.id]
        }
      ]
    }
  end
  let!(:copy_program) do
    create(
      :program,
      name: "Copy Test Program"
    )
  end
  let!(:program_phase) do
    create(
      :programs_phase,
      program_id: @program.id,
      phase_id: @phase.id
    )
  end

  describe "GET #edit" do
    context "when all required params are included" do
      before do
        get :edit, params: { id: @program.id }
      end

      it "renders the appropriate program template" do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "GET #edit_details" do
    context "when required program id parameter is provided" do
      before do
        get :edit_details, params: { id: @program.id }
      end

      it "returns appropriate program details" do
        expect(json["name"]).to eq(@program.name)
        expect(json["description"]).to eq(@program.description)
        expect(json["holistic_evaluation"]).to eq(@program.holistic_evaluation)
        expect(json["phases"][0]["name"]).to eq(@phase.name)
        expect(json["phases"][0]["assessments"]).to be_truthy
      end
    end
  end

  describe "PUT #update" do
    context "when appropriate program details are provided" do
      before do
        put :update, params: {
          program_id: @program.id,
          details: @details.to_json
        }
      end

      it "saves program details and returns saved status of true" do
        expect(json["saved"]).to eq(true)
        program = Program.eager_load(:language_stacks).find(@program.id)
        language_stacks = program.language_stacks
        phases = program.phases
        expect(language_stacks.count).to eq(1)
        expect(language_stacks[0].name).to eq(@details[:language_stacks][0])
        expect(program.name).to eq(@details[:name])
        expect(program.estimated_duration).to eq(5)
        expect(program.save_status).to eq(true)
        expect(phases.length).to eq(2)
        expect(phases[0].name).to eq(@details[:phases][0][:name])
        expect(phases[0].phase_decision_bridge).to eq(false)
        expect(phases[0].assessments.count).to eq(1)
        expect(phases[0].assessments[0].name).to eq(@second_assessment.name)
        expect(phases[1][:name]).to eq(@phase.name)
        expect(phases[1].phase_decision_bridge).to eq(true)
        expect(phases[1].assessments.count).to eq(1)
        expect(phases[1].assessments[0].name).to eq(@first_assessment.name)
      end
    end

    context "when existing program name is submitted" do
      before do
        @details[:name] = "Copy Test Program"
        put :update, params: {
          program_id: @program.id,
          details: @details.to_json
        }
      end

      it "returns saved status of false" do
        expect(json["saved"]).to eq(false)
      end
    end
  end
end
