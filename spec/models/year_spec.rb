require "rails_helper"

RSpec.describe Year, type: :model do
  describe "Year Associations" do
    it { is_expected.to have_many(:program_years) }
    it { is_expected.to have_many(:targets).through(:program_years) }
  end
end
