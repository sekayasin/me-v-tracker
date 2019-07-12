require "rails_helper"
require_relative "../../helpers/panelist_get_all_learners_controller_helper.rb"

RSpec.describe PitchController, type: :controller do
  let(:user) { create :user }
  let(:not_user) { create :user, :not_user }
  let(:admin) { create :user, :admin }

  before(:each) do
    pitch_create_program_helper
    pitch_panelist_create
    @pitch.update(created_by: admin.user_info[:email])
  end

  after(:each) do
    pitch_destroy_helper
  end
  describe "GET all learners in a pitch" do
    it "returns learners in active cycles" do
      get :show, params: { pitch_id: @pitch.id }
      expect(response.status).to eq(200)
      expect(response).to render_template("pitch/show")
    end
  end

  describe "GET all rated learners in a pitch" do
    before(:each) do
      stub_current_user(:admin)
      session[:current_user_info] = admin.user_info
    end

    it "returns learners rated average in a pitch" do
      get :show, params: { pitch_id: @pitch.id }
      expect(response.status).to eq(200)
      expect(response).to render_template("pitch/show")
    end
  end

  describe "An andela but non-panelist" do
    before(:each) do
      session[:current_user_info][:email] = "efe.faith@andela.com"
    end

    it "returns the user to not found page" do
      get :show, params: { pitch_id: @pitch.id }
      expect(response).to redirect_to(not_found_path)
    end
  end

  describe "Non recognize user" do
    before(:each) do
      stub_current_user(:not_user)
      session[:current_user_info] = not_user.user_info
    end

    it "logs out the user" do
      get :show, params: { pitch_id: @pitch.id }
      expect(response).to redirect_to(logout_path)
    end
  end

  describe "Admin should get learners and panelist for a pitch" do
    before(:each) do
      stub_current_user(:admin)
      session[:current_user_info] = admin.user_info
    end

    it "returns all the learners and panelists for that pitch" do
      get :show, params: { pitch_id: @pitch.id }
      expect(response).to render_template("pitch/show")
      expect(response.status).to eq(200)
    end
  end
end
