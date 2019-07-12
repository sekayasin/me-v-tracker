require "rails_helper"

RSpec.describe ScheduleFeedback, type: :model do
  describe "schedule feedback test cases" do
    it { is_expected.to belong_to(:nps_question) }
    it { is_expected.to belong_to(:cycle_center) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:cycle_center_id) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:program_id) }
    it { is_expected.to validate_presence_of(:nps_question_id) }
  end
end
