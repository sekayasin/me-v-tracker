require "rails_helper"

RSpec.describe SurveysV2Controller, type: :controller do
  describe "GET #recipients" do
    let(:admin) { create(:user, :admin) }
    before do
      stub_current_user(:admin)
      session[:current_user_info] = admin.user_info
      @cycle_center = create(:cycle_center, :ongoing)
    end

    it "returns active cycles" do
      get :get_recipients
      expect(response.status).to eq(200)
      expect(response.body).to include(@cycle_center.cycle_center_id)
    end
  end
end
