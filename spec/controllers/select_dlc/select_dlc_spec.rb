require "rails_helper"

RSpec.describe SelectDlcController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
  end

  describe "GET #index" do
    before do
      get :index
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
      expect(response).to have_http_status 200
    end
  end
end
