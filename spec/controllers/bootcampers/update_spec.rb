require "rails_helper"

RSpec.describe BootcampersController, type: :controller do
  let(:user) { create :user }
  let(:learner_program) { create :learner_program }
  let(:lfa) { "john.doe@andela.com" }
  let(:json) { JSON.parse(response.body) }

  describe "PUT #update" do
    before do
      stub_current_user(:user)
    end

    describe "an admin user" do
      before(:each) do
        create :facilitator, email: "john.doe@andela.com"
        allow(controller).to receive_message_chain(:helpers, :admin?).
          and_return true
      end

      context "when decision1 is advanced" do
        it "updates decision2 status to in progress" do
          put :update, params: { learner_program_id: learner_program.id,
                                 decision_one: "Advanced",
                                 format: :json }
          learner_program.reload
          expect(learner_program.decision_one).to eq "Advanced"
          expect(learner_program.decision_two).to eq "In Progress"
        end
      end

      context "when decision1 is in progress" do
        it "updates decision2 status to not applicable" do
          put :update, params: { learner_program_id: learner_program.id,
                                 decision_one: "In Progress",
                                 format: :json }
          learner_program.reload
          expect(learner_program.decision_one).to eq "In Progress"
          expect(learner_program.decision_two).to eq "Not Applicable"
        end
      end

      it "updates the week_one_lfa for a learner" do
        put :update, params: { learner_program_id: learner_program.id,
                               week_one_lfa: lfa,
                               format: :json }
        learner_program.reload
        expect(learner_program.week_one_facilitator.email).to eq lfa
      end

      it "updates the week_two_lfa for a learner" do
        put :update, params: { learner_program_id: learner_program.id,
                               week_two_lfa: lfa,
                               format: :json }
        learner_program.reload
        expect(learner_program.week_two_facilitator.email).to eq lfa
      end

      it "returns message after successful update" do
        put :update, params: { learner_program_id: learner_program.id,
                               decision_one: "Advanced",
                               format: :json }
        expect(json["message"]).to eq "status update successful"
      end

      context "when decision1 is accepted" do
        it "updates decision2 status to not applicable" do
          put :update, params: { learner_program_id: learner_program.id,
                                 decision_one: "Accepted",
                                 format: :json }
          learner_program.reload
          expect(learner_program.decision_one).to eq "Accepted"
          expect(learner_program.decision_two).to eq "Not Applicable"
        end
      end
    end

    describe "for a non admin user" do
      before(:each) do
        allow(controller).to receive_message_chain(:helpers, :admin?).
          and_return false
      end

      it "allows non admin user" do
        put :update, params: {
          learner_program_id: learner_program.id,
          decision_one: "Advanced"
        }
        expect(response.body).to eq ""
      end
    end
  end
end
