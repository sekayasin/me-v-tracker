require "rails_helper"
require "helpers/add_learner_helper_spec"

RSpec.describe BootcampersController, type: :controller do
  include AddLearnerHelpers
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }

  describe "POST #add" do
    before do
      stub_current_user(:user)
    end

    context "when spreadsheet is valid" do
      before do
        post_learner_data("samplelearner.xlsx")
      end

      it "uploads valid bootcampers" do
        post_learner_data("samplelearner.xlsx")
        expect(assigns[:existing_users]).not_to be_nil
      end

      it "returns json data" do
        expect(json.length).to eq 2
      end
    end

    context "when spreadsheet is invalid" do
      it "displays error message" do
        post_learner_data("invalid.xlsx")
        expect(assigns[:error]).to be_truthy
      end
    end

    context "when spreadsheet contains duplicate email address" do
      it "displays error message" do
        post_learner_data("vofduplicatemail.xlsx")
        expect(assigns[:error]).to be_truthy
      end
    end
  end
end
