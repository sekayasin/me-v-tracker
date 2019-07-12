require "rails_helper"

RSpec.describe BootcampersHelper, type: :helper do
  describe "bootcamper helper" do
    let(:bootcamper_learner_program) { create :learner_program }
    let(:bootcamper) { create :bootcamper }

    context "uploaded_cycle_url" do
      it "it returns cycle url" do
        @learner_program = bootcamper_learner_program
        expected = "/?program_id=#{@learner_program[:program_id]}&" \
        "city=#{@learner_program[:city]}&cycle=#{@learner_program[:cycle]}&" \
        "decision_one=All&decision_two=All&user_action=f"
        url = uploaded_cycle_url
        expect(url).to eq expected
      end
    end

    context "display_error_message" do
      it "validates one email" do
        error = { email: ["vof.learner@gmail.com"] }
        expected = "This email address occurs more than once:"
        message = display_error_message(error)
        expect(message).to eq expected
      end
      it "validates multiple emails" do
        error = { email: %w(vof.learner@gmail.com learner2@gmail.com) }
        expected = "The following email addresses occur more than once:"
        message = display_error_message(error)
        expect(message).to eq expected
      end
    end
    context "save decision" do
      it "returns success flash message " do
        params = { last_name: "learner" }
        message = save_decision(bootcamper, params)
        expect(message).to eq "decision-comments-success"
      end
      it "returns errors" do
        params = { email: "" }
        expected = "Email can't be blank"
        message = save_decision(bootcamper, params)
        expect(message).to eq expected
      end
    end
  end
end
