require "rails_helper"

RSpec.describe ProgramsController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let!(:program) { create :program, name: "Andela ALC" }
  let!(:first_phase) { create :phase, name: "ALC 1" }
  let!(:programs_phase) do
    create(:programs_phase, phase_id: first_phase.id, program_id: program.id)
  end
  let!(:second_phase) { create :phase, name: "ALC 2" }
  let!(:programs_phase) do
    create(:programs_phase, phase_id: second_phase.id, program_id: program.id)
  end
  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    controller.helpers.stub(:admin?) { true }
    request.env["HTTP_ACCEPT"] = "application/json"
    get :index,
        params: { size: 10, page: 1 }
  end
  describe "GET #index" do
    before do
      request.env["HTTP_ACCEPT"] = "text/html"
      get :index
    end
    it "renders index page in txt/html" do
      expect(response.content_type).to eq "text/html"
    end
    it "tenders index template " do
      expect(response).to render_template(:index)
    end
  end
  describe "GET #index" do
    context "when getting the list of all programs as an admin" do
      it "returns all programs in json format" do
        expect(response.content_type).to eq "application/json"
      end

      it "returns success" do
        expect(response).to be_success
      end

      it "returns finalised programs" do
        expect(json["paginated_data"][1]["name"]).to eq "Bootcamp v1"
        expect(json["paginated_data"][1]["save_status"]).to eq true
      end

      it "returns unfinalised programs" do
        expect(json["paginated_data"][0]["name"]).to eq "Andela ALC"
        expect(json["paginated_data"][0]["save_status"]).to eq false
      end
    end

    context "when getting the list of programs as a normal user" do
      before do
        controller.helpers.stub(:admin?) { false }
        get :index,
            params: { size: 10, page: 1 }
      end

      it "returns an unauthorized error" do
        expect(json["status"]).to eq 401
      end
    end
  end
end
