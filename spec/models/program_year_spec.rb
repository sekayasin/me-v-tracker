require "rails_helper"

RSpec.describe ProgramYear, type: :model do
  describe "ProgramYear Associations" do
    it { is_expected.to belong_to(:year) }
    it { is_expected.to belong_to(:target) }
  end
end
