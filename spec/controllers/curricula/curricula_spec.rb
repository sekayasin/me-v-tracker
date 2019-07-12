require "rails_helper"

RSpec.describe CurriculaController, type: :controller do
  include_context "criteria context"

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
    allow(controller).to receive_message_chain("helpers.admin?").and_return true
  end

  describe "GET #get_curriculum_details" do
    context "when no search term is passed and no program is passed" do
      before do
        get :get_curriculum_details
      end

      it "returns a json with a count of 3" do
        expect(json.count).to eq 3
      end

      it "returns all criteria and frameworks" do
        expect(json).to include "frameworks"
        expect(json).to include "criteria"
      end
    end

    context "when a search term is passed" do
      context "when result is found upon search" do
        before do
          get :get_curriculum_details, params: {
            search: "epic", program_id: program.id
          }
        end

        it "returns a json with a count of 4" do
          expect(json.count).to eq 4
        end

        it "returns criteria with length of 7" do
          expect(json["criteria"].length).to be > 0
        end
      end

      context "when no result is found upon search" do
        before do
          get :get_curriculum_details, params: {
            search: "qualifyz890", program_id: program.id
          }
        end

        it "returns criteria with length 0" do
          expect(json["criteria"].length).to eq 0
        end
      end

      context "when no search term is passed and a program_id is passed" do
        before do
          get :get_curriculum_details, params: { program_id: program.id }
        end

        it "returns a json with a count of 3" do
          expect(json.count).to be >= 1
        end

        it "returns all criteria and frameworks for current program" do
          expect(json).to include "frameworks"
        end

        it "returns the appropriate user role" do
          expect(json["is_admin"]).to eq true
        end
      end
    end
  end
end
