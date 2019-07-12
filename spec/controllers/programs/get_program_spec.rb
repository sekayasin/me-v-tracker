require "rails_helper"

RSpec.describe ProgramsController, type: :controller do
  let(:user) { create :user }
  let!(:program) { create :program }

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
  end

  describe "GET #get_program" do
    render_views
    let!(:response) do
      get :get_program,
          params: { id: program.id },
          format: :js,
          xhr: true
    end

    it "renders '_get_program' partial" do
      expect(response).to render_template(partial: "_get_program")
    end

    it "returns a JavaScript response" do
      expect(response.content_type).to eq Mime[:js]
    end

    it "returns a program that matches with supplied ID" do
      expect(response.body).to include program.name
    end

    it "returns a program instance variable" do
      expect(assigns(:program)).to_not eq nil
    end
  end
end
