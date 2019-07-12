require "rails_helper"

RSpec.describe LearningEcosystemController, type: :controller do
  let(:user) { create :user }
  let!(:program) do
    create :program, name: "BootCamp v1.5"
  end
  let!(:learner_program) { create :learner_program }
  let!(:phases) { create_list :phase, 7 }
  describe "GET #index" do
    let(:json) { JSON.parse(response.body) }
    before do
      stub_current_user :user
      session[:current_user_info] = learner_program.bootcamper
      phases.each_with_index do |phase, index|
        create :programs_phase, program_id: learner_program.program.id,
                                phase_id: phase.id, position: index + 1
      end

      get :index
    end

    it "renders index template" do
      expect(response).to render_template(:index)
      expect(response).to have_http_status 200
    end

    it "returns list of all frameworks" do
      frameworks = assigns(:frameworks)
      expect(frameworks.length).to eq(3)
      expect(frameworks[0][1]).to eq("Values Alignment")
      expect(frameworks[1][1]).to eq("Output Quality")
      expect(frameworks[2][1]).to eq("Feedback")
    end

    it "returns phases with the summary details" do
      phases_summary_details = assigns[:phases_summary]
      expect(phases_summary_details[0][:completed]).not_to be_nil
      expect(phases_summary_details[0][:name]).not_to be_nil
      expect(phases_summary_details[0][:total]).not_to be_nil
      expect(phases_summary_details[0][:percentage]).not_to be_nil
      expect(phases_summary_details[0][:phases]).not_to be_nil
      expect(phases_summary_details[0][:phases][0][:completed]).not_to be_nil
      expect(phases_summary_details[0][:phases][0][:percentage]).not_to be_nil
      expect(phases_summary_details[0][:phases][0][:total]).not_to be_nil
      expect(phases_summary_details[0][:phases][0][:name]).not_to be_nil
    end
  end
end
