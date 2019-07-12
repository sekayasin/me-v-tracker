require "rails_helper"

RSpec.describe BootcampersController, type: :controller do
  let(:user) { create :user }
  let(:center) { create(:center, name: "Lagos", country: "Nigeria") }
  let(:cycle) { create(:cycle) }
  let(:camper) { create(:bootcamper) }
  let(:cycle_center) do
    create(
      :cycle_center,
      center_id: center[:center_id],
      cycle_id: cycle[:cycle_id],
      end_date: Date.tomorrow
    )
  end
  let(:learner_program) do
    create(
      :learner_program,
      camper_id: camper[:camper_id],
      cycle_center_id: cycle_center[:cycle_center_id]
    )
  end
  describe "GET #get_learners" do
    before do
      stub_current_user(:user)
      learner_program
    end

    context "when user tries to get all bootcampers in a specific location" do
      it "returns all bootcampers in that location for ongoing bootcamp" do
        get :get_learners, params: {
          country: "Nigeria",
          name: "Lagos"
        }

        json_response = JSON.parse(response.body)
        learner = json_response["learners"][0]
        learner_program = json_response["learner_programs"][0]
        expect(json_response.length).to eq 2
        expect(learner["first_name"]).to eq camper[:first_name]
        expect(learner["last_name"]).to eq camper[:last_name]
        expect(learner["camper_id"]).to eq camper[:camper_id]
        expect(learner_program["camper_id"]).to eq camper[:camper_id]
      end

      it "returns an error if no ongoing bootcamp is found" do
        cycle_center.update(end_date: Date.yesterday)
        get :get_learners, params: {
          country: "Nigeria",
          name: "Lagos"
        }
        json_response = JSON.parse(response.body)
        expect(
          json_response["message"]
        ).to eq "No ongoing bootcamp at this location."
      end
    end
  end
end
