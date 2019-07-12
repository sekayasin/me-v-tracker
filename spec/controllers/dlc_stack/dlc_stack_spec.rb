require "rails_helper"

RSpec.describe DlcStackController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let(:program) { Program.first }

  before do
    stub_current_user(:user)
  end

  describe "GET #show_program_dlc_stack" do
    before do
      get :show_program_dlc_stack, params: { program_id: program.id }
    end

    it "returns the DLC stack for the particular program" do
      expect(json.length).to eq 2
      stacks = DlcStack.show_program_dlc_stack(program.id)
      first_stack_name = stacks.first.language_stack.name
      second_stack_name = stacks.second.language_stack.name
      expect(json[0]["dlc_stack_name"]).to eq first_stack_name
      expect(json[1]["dlc_stack_name"]).to eq second_stack_name
    end
  end
end
