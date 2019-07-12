require "rails_helper"

RSpec.describe CurriculaController, type: :controller do
  let!(:bootcamper) { create :bootcamper_with_learner_program }
  let!(:program) { create :program }

  describe "GET #index" do
    before do
      stub_current_user(:bootcamper)
      get :index
    end

    it "renders index template" do
      expect(response).to render_template(:index)
    end

    it "returns correct list of all frameworks" do
      frameworks = assigns(:frameworks)
      expect(frameworks.length).to eq(3)
      expect(frameworks[0][1]).to eq("Values Alignment")
      expect(frameworks[1][1]).to eq("Output Quality")
      expect(frameworks[2][1]).to eq("Feedback")
    end
  end
end
