require "rails_helper"

RSpec.describe ProgramsController, type: :controller do
  include_context "new program details"

  describe "POST #create" do
    context "when all required params are included" do
      before do
        create_program(params)
      end

      it "creates a new program" do
        new_program = Program.second

        expect(new_program[:name]).to eq params[:program][:name]
        expect(new_program[:description]).to eq params[:program][:description]
      end

      it "creates phases for the created program" do
        new_program_phases = ProgramsPhase.where(
          program_id: Program.second[:id]
        ).includes(:phase).order("id asc")
        expected_phase = new_program_phases[0].phase[:name]

        expect(new_program_phases.length).to eq 2
        expect(expected_phase).
          to eq params[:program][:phases][0].split.map(&:capitalize).join(" ")
      end

      it "returns the created program" do
        expect(json["program"]["name"]).to eq "Bootcamp V5"
      end
    end

    context "when program name exists already" do
      before do
        params[:program][:name] = "Bootcamp v1"
        create_program(params)
      end

      it "does not create a new program" do
        expect(Program.all.count).to eq 1
      end

      it "returns an error message" do
        expect(json["error"]).to eq "Name has already been taken"
      end
    end

    context "when params contains a program id" do
      before do
        create_program(clone_params)
      end

      it "clones the program details and creates a new one" do
        expect(json["program"]["name"]).to eq "Cloned Program"
        expect(json["program"]["description"]).to eq "fellow selection process"
      end
    end

    context "when phases are not included in params" do
      before do
        params[:program][:phases] = []
        create_program(params)
      end

      it "does not create a new program" do
        expect(Program.all.count).to eq 1
      end

      it "displays appropriate error json message" do
        expect(json["error"]).to eq "Phases cannot be blank!"
      end
    end
  end
end
