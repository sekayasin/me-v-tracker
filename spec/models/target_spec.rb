require "rails_helper"

RSpec.describe Target, type: :model do
  describe "Target Associations" do
    it { is_expected.to have_many(:years).through(:program_years) }
  end
end
