require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "#set_status_color" do
    let(:learner_program) { create :learner_program }
    let(:user) { create :user }
    context "when camper's week 1 status is rejected" do
      it "concatenates string 'status-' with week 1 status" do
        learner_program.update(decision_one: "Rejected")
        status_color = set_status_color(learner_program.decision_one)
        expect(status_color).to eq "status-rejected"
      end
    end

    context "when camper's week 2 status is accepted " do
      it "concatenates string 'status-' with week 2 status" do
        learner_program.update(decision_two: "Accepted")
        status_color = set_status_color(learner_program.decision_two)
        expect(status_color).to eq "status-accepted"
      end
    end

    describe "nil learner values" do
      decisions = { decision_one: "In Progress", decision_two: "Not Applicable",
                    week_two_lfa: "Unassigned" }
      context "when learner decision one is blank?" do
        it "returns 'In Progress'" do
          data = { decision_one: nil }
          decision_one = set_stubs(data[:decision_one], "decision_one")
          expect(decision_one).to eq decisions[:decision_one]
        end
      end
      context "when learner decision two is blank?" do
        it "returns 'Not Applicable'" do
          data = { decision_two: nil }
          decision_two = set_stubs(data[:decision_two], "decision_two")
          expect(decision_two).to eq decisions[:decision_two]
        end
      end
      context "when learners week_two_lfa is blank?" do
        it "returns 'Unassigned'" do
          data = { week_two_lfa: nil }
          week_two_lfa = set_stubs(data[:week_two_lfa], "week_two_lfa")
          expect(week_two_lfa).to eq decisions[:week_two_lfa]
        end
      end

      context ".set_metric_description" do
        let(:metric) { create :metric }
        it "sets metric description" do
          description = set_metric_description(metric)
          expect(description).to eq "No output submitted"
        end
      end

      context "check if user is test admin" do
        @email = "admin@andela.com"
        it "returns true if test admin" do
          admin = user_is_test_admin?(@email)
          expect(admin).to be false
        end
      end

      context "check admin actions" do
        it "returns admin actions" do
          session[:current_user_info] = {
            email: "admin@andela.com"
          }
          actions = admin_actions
          expect(actions).to be nil
        end
      end
    end
  end
end
