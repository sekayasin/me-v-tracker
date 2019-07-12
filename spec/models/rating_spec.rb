require "rails_helper"

RSpec.describe Rating, type: :model do
  describe "Association" do
    it { should belong_to(:learners_pitch) }
    it { should belong_to(:panelist) }
  end
  describe "Validations" do
    it { validate_presence_of(:learners_pitch_id) }
    it { validate_presence_of(:panelist_id) }
    it { validate_presence_of(:ui_ux) }
    it { validate_presence_of(:api_functionality) }
    it { validate_presence_of(:error_handling) }
    it { validate_presence_of(:project_understanding) }
    it { validate_presence_of(:presentational_skill) }
    it { validate_presence_of(:decision) }
    it { validate_presence_of(:comment) }
  end
end
