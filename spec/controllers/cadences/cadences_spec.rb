require "rails_helper"

RSpec.describe CadencesController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let(:response) do
    get :index,
        format: :json,
        xhr: true
  end

  before do
    stub_current_user(:user)
  end

  describe "GET #index" do
    it "returns a JSON response" do
      expect(response.content_type).to eq Mime[:json]
    end

    it "returns all cadences" do
      expect(json.length).to eq 3
    end
  end
end
