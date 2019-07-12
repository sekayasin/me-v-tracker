require "rails_helper"

# Specs in this file have access to a helper object that includes
# the ProfileHelper. For example:
#
# describe ProfileHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ProfileHelper, type: :helper do
  let(:user) { create :user }
  let(:inactive_cycle_center) do
    create(:cycle_center, start_date: Date.parse("2018-4-18"),
                          end_date: Date.parse("2018-4-25"))
  end
  let(:cycle_center_in_grace) do
    create(:cycle_center, start_date: 1.week.ago,
                          end_date: Date.yesterday)
  end
  describe "display lfa details" do
    context "when lfa email is passed" do
      it "renders a partial with the lfa's name and email" do
        response = display_lfa_details("kachi.okereke@kachi.com")
        expect(response).to match "Kachi Okereke"
        expect(response).to match "kachi.okereke@kachi.com"
      end
    end

    context "when no email is passed" do
      it "renders text saying that an LFA hasn't been assigned" do
        response = display_lfa_details(nil)
        expect(response).to match "No LFA assigned yet"
      end
    end

    context "when the learner has an unassigned LFA" do
      it "renders a Nil text when the learner has an unassigned LFA" do
        response = display_lfa_details("Unassigned@andela.com")
        expect(response).to match "-"
      end
    end

    describe "Editing When the bootcamp has ended" do
      context "for admin," do
        it "returns false if grace period has elapsed" do
          allow_any_instance_of(ApplicationHelper).to receive(
            :admin?
          ).and_return true
          expect(can_edit_scores?(user.user_info[:id],
                                  inactive_cycle_center.id)).to be false
        end

        it "returns true if it is still in grace period" do
          allow_any_instance_of(ApplicationHelper).to receive(
            :admin?
          ).and_return true
          expect(can_edit_scores?(user.user_info[:id],
                                  cycle_center_in_grace.id)).to be true
        end
      end
      xcontext "for lfa," do
        it "returns false if it has ended" do
          allow_any_instance_of(ApplicationHelper).to receive(
            :user_is_lfa?
          ).and_return true
          allow_any_instance_of(ApplicationHelper).to receive(
            :admin?
          ).and_return false
          expect(can_edit_scores?(user.user_info[:id],
                                  cycle_center_in_grace.id)).to be false
        end
      end
    end
  end
end
