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

  describe "PUT #update_lfa" do
    before do
      stub_current_user(:user)
      learner_program
      selected_learners = [camper[:camper_id]]
      put :update_lfa, params: {
        lfaEmail: "week1.user@andela.com",
        selectedLearners: selected_learners,
        week: "Week 1"
      }
    end

    context "when user tries to add a new Lfa for week 1" do
      it "saves the lfa to the database" do
        lfa = Facilitator.where(
          email: "week1.user@andela.com"
        )
        expect(lfa.blank?).to be false
      end

      it "updates learner program table with lfa id" do
        lfa = Facilitator.where(
          email: "week1.user@andela.com"
        ).first
        learner_program.reload
        expect(learner_program[:week_one_facilitator_id]).to eq lfa[:id]
      end

      it "returns successful response" do
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq "Facilitator update successful."
      end
    end

    before do
      stub_current_user(:user)
      learner_program
      selected_learners = [camper[:camper_id]]
      put :update_lfa, params: {
        lfaEmail: "week2.user@andela.com",
        selectedLearners: selected_learners,
        week: "Week 2"
      }
    end

    context "when user tries to add a new Lfa for week 2" do
      it "saves the lfa to the database" do
        lfa = Facilitator.where(
          email: "week2.user@andela.com"
        )
        expect(lfa.blank?).to be false
      end

      it "updates learner program table with lfa id" do
        lfa = Facilitator.where(
          email: "week2.user@andela.com"
        ).first
        learner_program.reload
        expect(learner_program[:week_two_facilitator_id]).to eq lfa[:id]
      end

      it "returns successful response" do
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq "Facilitator update successful."
      end
    end
  end
end
