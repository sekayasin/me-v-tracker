require "rails_helper"

RSpec.describe DecisionsController, type: :controller do
  let(:user) { create :user }
  let(:first_learner_program) do
    create :learner_program,
           decision_one: "Advanced",
           decision_two: "Accepted"
  end
  let(:second_learner_program) { create :learner_program }
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    @valid_decision = create(
      :decision,
      learner_programs_id: first_learner_program.id
    )
    @invalid_decision = create(
      :decision,
      learner_programs_id: second_learner_program.id
    )
  end

  after :all do
    Decision.delete_all
  end

  describe "GET #get_history" do
    context "when there is no decision for the learner" do
      it "returns empty array" do
        get :get_history, params: { learner_program_id: 629 }

        expect(json).to eq([])
      end
    end

    context "when the decision status is 'In Progress' or 'Not Applicable'" do
      it "returns empty array" do
        get :get_history,
            params: { learner_program_id: second_learner_program.id }

        expect(json).to eq([])
      end
    end

    context "when there are decisions" do
      it "gets correct decision history" do
        get :get_history, params: {
          learner_program_id: first_learner_program.id
        }

        expected_name = first_learner_program.
                        week_one_facilitator.
                        email.
                        split("@")[0].split(".").join(" ")

        expect(json[0]["details"]["LFA"].downcase).to eq(expected_name)
        expect(json[0]["details"]["Comment"]).to eq(@valid_decision.comment)
      end
    end
  end
end
