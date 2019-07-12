require "rails_helper"

RSpec.describe ProgramsController, type: :controller do
  let(:user) { create :user }
  let(:program) do
    create :program,
           estimated_duration: 5,
           save_status: true
  end
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
    RedisService.delete_all_keys
  end

  describe "GET #get_program_assessments" do
    context "when a program exist" do
      it "returns the program details" do
        get :get_program_assessments, params: { program_id: program.id }

        expect(json["duration"]).to eq(5)
        expect(json["cadence"]).to eq("Weekly")
        expect(json["language_stack"]).to eq([])
        expect(json["assessments"]).to eq([])
      end
    end

    context "when a program does not exist" do
      it "returns an error message" do
        get :get_program_assessments, params: { program_id: 26 }

        expect(json["error"]).to eq("Program was not found")
      end
    end
  end
end
